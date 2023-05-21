package xurlfind3r

import (
	"regexp"
	"sync"

	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources"
	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources/commoncrawl"
	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources/github"
	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources/intelx"
	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources/otx"
	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources/urlscan"
	"github.com/hueristiq/xurlfind3r/pkg/xurlfind3r/sources/wayback"
)

type Options struct {
	Domain             string
	IncludeSubdomains  bool
	Sources            []string
	Keys               sources.Keys
	ParseWaybackRobots bool
	ParseWaybackSource bool
}

type Finder struct {
	Sources              map[string]sources.Source
	SourcesConfiguration *sources.Configuration
}

func New(options *Options) (finder *Finder) {
	finder = &Finder{
		Sources: map[string]sources.Source{},
		SourcesConfiguration: &sources.Configuration{
			Keys:               options.Keys,
			Domain:             options.Domain,
			IncludeSubdomains:  options.IncludeSubdomains,
			ParseWaybackRobots: options.ParseWaybackRobots,
			ParseWaybackSource: options.ParseWaybackSource,
			URLsRegex:          regexp.MustCompile(`(?:"|')(((?:[a-zA-Z]{1,10}://|//)[^"'/]{1,}\.[a-zA-Z]{2,}[^"']{0,})|((?:/|\.\./|\./)[^"'><,;| *()(%%$^/\\\[\]][^"'><,;|()]{1,})|([a-zA-Z0-9_\-/]{1,}/[a-zA-Z0-9_\-/]{1,}\.(?:[a-zA-Z]{1,4}|action)(?:[\?|#][^"|']{0,}|))|([a-zA-Z0-9_\-/]{1,}/[a-zA-Z0-9_\-/]{3,}(?:[\?|#][^"|']{0,}|))|([a-zA-Z0-9_\-]{1,}\.(?:php|asp|aspx|jsp|json|action|html|js|txt|xml)(?:[\?|#][^"|']{0,}|)))(?:"|')`), //nolint:gocritic // Works so far
			MediaURLsRegex:     regexp.MustCompile(`(?i)\.(apng|bpm|png|bmp|gif|heif|ico|cur|jpg|jpeg|jfif|pjp|pjpeg|psd|raw|svg|tif|tiff|webp|xbm|3gp|aac|flac|mpg|mpeg|mp3|mp4|m4a|m4v|m4p|oga|ogg|ogv|mov|wav|webm|eot|woff|woff2|ttf|otf|css)(?:\?|#|$)`),
			RobotsURLsRegex:    regexp.MustCompile(`^(https?)://[^ "]+/robots.txt$`),
		},
	}

	for index := range options.Sources {
		source := options.Sources[index]

		switch source {
		case "commoncrawl":
			finder.Sources[source] = &commoncrawl.Source{}
		case "github":
			finder.Sources[source] = &github.Source{}
		case "intelx":
			finder.Sources[source] = &intelx.Source{}
		case "otx":
			finder.Sources[source] = &otx.Source{}
		case "urlscan":
			finder.Sources[source] = &urlscan.Source{}
		case "wayback":
			finder.Sources[source] = &wayback.Source{}
		}
	}

	return
}

func (finder *Finder) Find() (URLs chan sources.URL) {
	URLs = make(chan sources.URL)

	go func() {
		defer close(URLs)

		wg := &sync.WaitGroup{}
		seen := &sync.Map{}

		for name := range finder.Sources {
			wg.Add(1)

			go func(source sources.Source) {
				defer wg.Done()

				for URL := range source.Run(finder.SourcesConfiguration) {
					value := URL.Value

					_, loaded := seen.LoadOrStore(value, struct{}{})
					if loaded {
						continue
					}

					URLs <- URL
				}
			}(finder.Sources[name])
		}

		wg.Wait()
	}()

	return
}

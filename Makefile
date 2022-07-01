default: index.html fonts.css

pub: _pub/index.html _pub/style.css _pub/fonts.css

clean:
	rm -f index.html fonts.css

index.html: *.sh.html content.md policy.json policy.sh
	esh index.sh.html > $@

fonts.css: fonts.sh.css fonts/*/stylesheet.css
	esh $< > $@

policy.json: policy.sh
	./policy.sh gen

_pub/%: %
	cp -au $< $@

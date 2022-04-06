default: index.html fonts.css

pub: _pub/index.html _pub/style.css _pub/fonts.css

index.html: *.sh.html
	esh index.sh.html > $@

fonts.css: fonts.sh.css fonts/*/stylesheet.css
	esh $< > $@

_pub/%: %
	cp -au $< $@

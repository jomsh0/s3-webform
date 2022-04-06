default: index.html fonts.css

pub: _pub/index.html _pub/style.css _pub/fonts.css

index.html: index.sh.html form.sh.html
	esh index.sh.html > index.html

fonts.css: fonts.sh.css fonts/*/stylesheet.css
	esh fonts.sh.css > fonts.css

_pub/%: %
	cp -au $< $@

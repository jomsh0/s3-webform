default: index.html fonts.css

pub: _pub/index.html _pub/style.css _pub/fonts.css

index.html: *.sh.html content.md policy.json gen_sig.sh qp.sh
	esh index.sh.html > $@

fonts.css: fonts.sh.css fonts/*/stylesheet.css
	esh $< > $@

policy.json: gen_policy.sh
	./gen_policy.sh > $@

_pub/%: %
	cp -au $< $@

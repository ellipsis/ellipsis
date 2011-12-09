/* use strict */
XML.ignoreWhitespace = false;
XML.prettyPrinting = false;
var INFO =
<plugin name="curl" version="0.2"
        href="http://dactyl.sf.net/pentadactyl/plugins#curl-plugin"
        summary="Curl command-line generator"
        xmlns={NS}>
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Pentadactyl" min-version="1.0"/>
    <p>
        This plugin provides a means to generate a <tt>curl(1)</tt>
        command-line from the data in a given form.
    </p>
    <item>
        <tags>;C</tags>
        <strut/>
        <spec>;C</spec>
        <description>
            <p>
                Generates a curl command-line from the data in the selected form.
                The command includes the data from each form element, along with
                the current User-Agent string and the cookies for the current
                page.
            </p>
        </description>
    </item>
</plugin>;

hints.addMode('C', "Generate curl command for a form", function(elem) {
    if (elem.form)
        var { url, postData, elements } = DOM(elem).formData;
    else
        var url = elem.getAttribute("href");

    if (!url || /^javascript:/.test(url))
        return;

    url = services.io.newURI(url, null, util.newURI(elem.ownerDocument.URL)).spec;

    let escape = util.closure.shellEscape;

    dactyl.clipboardWrite(["curl"].concat(
        [].concat(
            [["--form-string", escape(datum)] for ([n, datum] in Iterator(elements || []))],
            postData != null && !elements.length ? [["-d", escape("")]] : [],
            [["-H", escape("Cookie: " + elem.ownerDocument.cookie)],
             ["-A", escape(navigator.userAgent)],
             [escape(url)]]
        ).map(function(e) e.join(" ")).join(" \\\n\t")).join(" "), true);
});

/* vim:se sts=4 sw=4 et: */

"use strict";
XML.ignoreWhitespace = XML.prettyPrinting = false;
var INFO =
<plugin name="smooth-scroll" version="0.2"
        href="http://dactyl.sf.net/pentadactyl/plugins#smooth-scroll-plugin"
        summary="Smooth Scrolling Plugin"
        xmlns={NS}>
    <author email="maglione.k@gmail.com">Kris Maglione</author>
    <license href="http://opensource.org/licenses/mit-license.php">MIT</license>
    <project name="Pentadactyl" min-version="1.0"/>
    <p>
        This plugin enables smooth-scrolling in {config.name}'s scrolling commands.
    </p>
    <item>
        <tags>'ss' 'scrollsteps'</tags>
        <spec>'scrollsteps'</spec>
        <type>number</type>
        <default>5</default>
        <description>
            <p>The number of steps in which to smooth scroll to a new position.</p>
        </description>
    </item>
    <item>
        <tags>'st' 'scrolltime'</tags>
        <spec>'scrolltime'</spec>
        <type>number</type>
        <default>100</default>
        <description>
            <p>The time, in milliseconds, in which to smooth scroll to a new position.</p>
        </description>
    </item>
</plugin>;

group.options.add(["scrolltime", "st"],
    "The time, in milliseconds, in which to smooth scroll to a new position",
    "number", 100);
group.options.add(["scrollsteps", "ss"],
    "The number of steps in which to smooth scroll to a new position",
    "number", 5,
    { validator: function (value) value > 0 });

function smoothScroll(elem, x, y) {
    let time = options["scrolltime"];
    let steps = options["scrollsteps"];

    if (elem.dactylScrollTimer)
        elem.dactylScrollTimer.cancel();

    x = elem.dactylScrollDestX = Math.min(x, elem.scrollWidth  - elem.clientWidth);
    y = elem.dactylScrollDestY = Math.min(y, elem.scrollHeight - elem.clientHeight);
    let [startX, startY] = [elem.scrollLeft, elem.scrollTop];
    let n = 0;
    (function next() {
        if (n++ === steps) {
            elem.scrollLeft = x;
            elem.scrollTop  = y;
            delete elem.dactylScrollDestX;
            delete elem.dactylScrollDestY;
        }
        else {
            elem.scrollLeft = startX + (x - startX) / steps * n;
            elem.scrollTop  = startY + (y - startY) / steps * n;
            elem.dactylScrollTimer = util.timeout(next, time / steps);
        }
    }).call(this);
}

var onUnload = overlay.overlayObject(Buffer, {
    scrollTo: function scrollTo(elem, left, top) {
        smoothScroll(elem,
                     left == null ? elem.scrollLeft : left,
                     top == null  ? elem.scrollTop  : top);
    }
});

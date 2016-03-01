# extension.bash
#
# Functions used by ellipsis extensions.

load utils

# Check if ellipsis version is compatible
extension.is_compatible() {
    utils.version_compare "$ELLIPSIS_VERSION" -ge "${1:-$ELLIPSIS_VERSION_DEP}"
}

VERSION = "0.1"

def import_aal(version: str):
    import gi
    gi.require_version("Aal", version)
    from gi.repository import Aal
    return Aal

Aal = import_aal(VERSION)

#include "cmark-gfm-core-extensions.h"
#include "mlem_inlines.h"
#include "mlem_links.h"
#include "autolink.h"
#include "table.h"
#include "spoiler.h"
#include "registry.h"
#include "plugin.h"

static int core_extensions_registration(cmark_plugin *plugin) {
  cmark_plugin_register_syntax_extension(plugin, create_table_extension());
  cmark_plugin_register_syntax_extension(plugin, create_autolink_extension());
  cmark_plugin_register_syntax_extension(plugin, create_mlem_inlines_extension());
  cmark_plugin_register_syntax_extension(plugin, create_mlem_links_extension());
  cmark_plugin_register_syntax_extension(plugin, create_spoiler_extension()); 
  return 1;
}

void cmark_gfm_core_extensions_ensure_registered(void) {
  static int registered = 0;

  if (!registered) {
    cmark_register_plugin(core_extensions_registration);
    registered = 1;
  }
}

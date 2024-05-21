#ifndef CMARK_GFM_MLEM_LINKS_H
#define CMARK_GFM_MLEM_LINKS_H

#include "cmark-gfm-extension_api.h"
#include "cmark-gfm_export.h"

extern const char *cmark_lemmy_link_get_name(cmark_node *node);
extern const char *cmark_lemmy_link_get_domain(cmark_node *node);
extern const char *cmark_lemmy_link_get_content(cmark_node *node);
extern const int cmark_lemmy_link_get_is_community(cmark_node *node);

extern cmark_node_type CMARK_NODE_LEMMY_LINK;
cmark_syntax_extension *create_mlem_links_extension(void);

#endif

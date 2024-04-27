#ifndef CMARK_GFM_MLEM_INLINES_H
#define CMARK_GFM_MLEM_INLINES_H

#include "cmark-gfm-extension_api.h"
#include "cmark-gfm_export.h"

extern cmark_node_type CMARK_NODE_STRIKETHROUGH, CMARK_NODE_SUBSCRIPT, CMARK_NODE_SUPERSCRIPT;
cmark_syntax_extension *create_mlem_inlines_extension(void);

#endif

#include "mlem_inlines.h"
#include "ext_scanners.h"
#include <parser.h>
#include <render.h>
#include <houdini.h>
#include <node.h>

cmark_node_type CMARK_NODE_SPOILER;

static inline bool S_is_line_end_char(char c) {
  return (c == '\n' || c == '\r');
}

static inline bool S_is_space_or_tab(char c) {
  return (c == ' ' || c == '\t');
}

#define peek_at(i, n) i[n]

typedef struct {
  unsigned char *title;
  uint8_t fence_length;
} cmark_spoiler;

const char *cmark_spoiler_get_title(cmark_node *node) {
  if (node == NULL) {
    return NULL;
  }

  if (node->type == CMARK_NODE_SPOILER) {
     return ((cmark_spoiler *)node->as.opaque)->title;
  }

  return NULL;
}

static int matches(cmark_syntax_extension *self, cmark_parser *parser,
                   unsigned char *input, int len,
                   cmark_node *parent_container) {
  int res = 0;

  bufsize_t matched = scan_close_spoiler_fence(input, len, parser->first_nonspace);

  if (matched > 0) {
    cmark_parser_advance_offset(parser, input, matched, false);
  } else {
    res = true;
  }

  return res;
}

static cmark_node *try_opening_spoiler_block(cmark_syntax_extension *self,
                                           int indented, cmark_parser *parser,
                                           cmark_node *parent_container,
                                           unsigned char *input, int len) {
  cmark_node_type parent_type = cmark_node_get_type(parent_container);

  bufsize_t matched = 0;

    if (!indented && parent_type != CMARK_NODE_SPOILER) {
      matched = scan_open_spoiler_fence(
          input, len, cmark_parser_get_first_nonspace(parser));
    }
    if (matched == 0) {
      return NULL;
    }

    cmark_node *spoiler_node = cmark_parser_add_child(parser, parent_container, CMARK_NODE_SPOILER,
                            parser->first_nonspace + 1);

    spoiler_node->as.opaque = (cmark_spoiler *)parser->mem->calloc(
      1, sizeof(cmark_spoiler));

    bufsize_t start = parser->offset;
    cmark_parser_advance_offset(parser, input, matched, true);
    ((cmark_spoiler *)spoiler_node->as.opaque)->fence_length = (matched > 255) ? 255 : matched;
    cmark_strbuf *info = parser->mem->calloc(1, sizeof(cmark_strbuf));
    bufsize_t offset = parser->offset - start;
    cmark_strbuf_init(parser->mem, info, len - matched);
    cmark_strbuf_put(info, input + offset, len - matched);
    cmark_strbuf_trim(info);

    if (cmark_strbuf_len(info) == 0) {
       ((cmark_spoiler *)spoiler_node->as.opaque)->title = NULL;
    } else {
      ((cmark_spoiler *)spoiler_node->as.opaque)->title = (char *)info->ptr;
    }

    cmark_node_set_syntax_extension(spoiler_node, self);
    cmark_parser_advance_offset(parser, (char *)input,
                                len - cmark_parser_get_offset(parser), 0);

    return spoiler_node;
}


static int can_contain(cmark_syntax_extension *extension, cmark_node *node,
                       cmark_node_type child_type) {
  if (node->type == CMARK_NODE_SPOILER) {
    return CMARK_NODE_TYPE_BLOCK_P(child_type);
  }
  return false;
}

static const char *get_type_string(cmark_syntax_extension *extension,
                                   cmark_node *node) {
  if (node->type == CMARK_NODE_SPOILER)
    return "spoiler";
  return "<unknown>";
}

cmark_syntax_extension *create_spoiler_extension(void) {
  cmark_syntax_extension *ext = cmark_syntax_extension_new("spoiler");
  cmark_llist *special_chars = NULL;

  cmark_syntax_extension_set_match_block_func(ext, matches);
  cmark_syntax_extension_set_open_block_func(ext, try_opening_spoiler_block);
  cmark_syntax_extension_set_get_type_string_func(ext, get_type_string);
  cmark_syntax_extension_set_can_contain_func(ext, can_contain);
  CMARK_NODE_SPOILER = cmark_syntax_extension_add_node(0);

  return ext;
}

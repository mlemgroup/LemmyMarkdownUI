#include "mlem_links.h"
#include <parser.h>
#include <render.h>

cmark_node_type CMARK_NODE_LEMMY_LINK;

typedef struct {
  bool is_community;
  unsigned char *name;
  unsigned char *domain;
  unsigned char *content;
} cmark_lemmy_link;

const char *cmark_lemmy_link_get_name(cmark_node *node) {
  if (node == NULL) {
    return NULL;
  }

  if (node->type == CMARK_NODE_LEMMY_LINK) {
     return ((cmark_lemmy_link *)node->as.opaque)->name;
  }

  return NULL;
}

const char *cmark_lemmy_link_get_domain(cmark_node *node) {
  if (node == NULL) {
    return NULL;
  }

  if (node->type == CMARK_NODE_LEMMY_LINK) {
     return ((cmark_lemmy_link *)node->as.opaque)->domain;
  }

  return NULL;
}

const int cmark_lemmy_link_get_is_community(cmark_node *node) {
  if (node == NULL) {
    return NULL;
  }

  if (node->type == CMARK_NODE_LEMMY_LINK) {
     return ((cmark_lemmy_link *)node->as.opaque)->is_community;
  }

  return NULL;
}

const char *cmark_lemmy_link_get_content(cmark_node *node) {
  if (node == NULL) {
    return NULL;
  }

  if (node->type == CMARK_NODE_LEMMY_LINK) {
     return ((cmark_lemmy_link *)node->as.opaque)->content;
  }

  return NULL;
}

static cmark_node *match(cmark_syntax_extension *self, cmark_parser *parser,
                         cmark_node *parent, unsigned char character,
                         cmark_inline_parser *inline_parser) {
  cmark_node *res = NULL;

  if (character != '@') {
    return NULL;
  }

  cmark_chunk *chunk = cmark_inline_parser_get_chunk(inline_parser);
  size_t divider_pos = cmark_inline_parser_get_offset(inline_parser);
  uint8_t *data = chunk->data;
  size_t size = chunk->len;
  int start_col = cmark_inline_parser_get_column(inline_parser);

  if (divider_pos == 0) {
    return NULL;
  }

  // `1` if community, `0` if user
  bool is_community = 0;

  // Find the start of the link
  size_t link_start = divider_pos - 1;

  int prefix_length = 1;

  char this_char;
  while (link_start >= 0) {
    this_char = (char)data[link_start];
    if (this_char == '!') {
      is_community = 1;
      break;
    }
    if (this_char == '@') {
      break;
    }

    if (this_char == ' ' || link_start == 0) {
      // Check for `/c/history@lemmygrad.ml` link syntax
      if (this_char == ' ') {
        link_start++;
      }
      if (data[link_start] == '/' && data[link_start + 2] == '/') {
        prefix_length += 2;
        if (data[link_start+1] == 'c') {
          is_community = 1;
          break;
        } else if (data[link_start+1] == 'u') {
          break;
        }
      }
      return NULL;
    }
    link_start--;
  }

  size_t link_end = divider_pos;
  while (link_end < size && !cmark_isspace(data[link_end]))
    link_end++;

  cmark_inline_parser_set_offset(inline_parser, (int)(link_end));
  cmark_node_unput(parent, divider_pos-link_start);

  cmark_node *node = cmark_node_new_with_mem(CMARK_NODE_LEMMY_LINK, parser->mem);

  node->as.opaque = (cmark_lemmy_link *)parser->mem->calloc(1, sizeof(cmark_lemmy_link));

  // Extract name and domain separately

  cmark_strbuf buf;

  // content
  cmark_strbuf_init(parser->mem, &buf, 10);
  cmark_strbuf_put(&buf, data, (bufsize_t)(link_end));
  cmark_strbuf_drop(&buf, link_start); 
  ((cmark_lemmy_link *)node->as.opaque)->content = cmark_strbuf_detach(&buf);

  // name
  cmark_strbuf_init(parser->mem, &buf, 10);
  cmark_strbuf_put(&buf, data, (bufsize_t)(divider_pos));
  cmark_strbuf_drop(&buf, link_start + prefix_length);
  ((cmark_lemmy_link *)node->as.opaque)->name = cmark_strbuf_detach(&buf);

  // domain
  cmark_strbuf_init(parser->mem, &buf, 10);
  cmark_strbuf_put(&buf, data, (bufsize_t)(link_end));
  cmark_strbuf_drop(&buf, divider_pos + 1); 
  ((cmark_lemmy_link *)node->as.opaque)->domain = cmark_strbuf_detach(&buf);

  // type
  ((cmark_lemmy_link *)node->as.opaque)->is_community = is_community;

  node->start_line = node->end_line = cmark_inline_parser_get_line(inline_parser);

  node->start_column = (int)link_start + 1;
  node->end_column = cmark_inline_parser_get_column(inline_parser) - 1;

  cmark_node_set_syntax_extension(node, self);

  return node;
}

static const char *get_type_string(cmark_syntax_extension *extension,
                                   cmark_node *node) {
  if (node->type == CMARK_NODE_LEMMY_LINK)
    return "lemmy_link";
  return "<unknown>";
}

static int can_contain(cmark_syntax_extension *extension, cmark_node *node,
                       cmark_node_type child_type) {
  if (!(node->type == CMARK_NODE_LEMMY_LINK))
    return false;

  return child_type == CMARK_NODE_TEXT;
}

cmark_syntax_extension *create_mlem_links_extension(void) {
  cmark_syntax_extension *ext = cmark_syntax_extension_new("mlem_links");
  cmark_llist *special_chars = NULL;

  cmark_syntax_extension_set_get_type_string_func(ext, get_type_string);
  cmark_syntax_extension_set_can_contain_func(ext, can_contain);

  CMARK_NODE_LEMMY_LINK = cmark_syntax_extension_add_node(1);

  cmark_syntax_extension_set_match_inline_func(ext, match);

  cmark_mem *mem = cmark_get_default_mem_allocator();
  special_chars = cmark_llist_append(mem, special_chars, (void *)'@');
  cmark_syntax_extension_set_special_inline_chars(ext, special_chars);

  cmark_syntax_extension_set_emphasis(ext, 1);

  return ext;
}

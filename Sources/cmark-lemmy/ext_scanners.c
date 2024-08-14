/* Generated by re2c 3.1 on Mon Aug 12 15:36:56 2024 */
#line 1 "ext_scanners.re"
#line 1 "ext_scanners.re"


#include <stdlib.h>
#include "ext_scanners.h"

bufsize_t _ext_scan_at(bufsize_t (*scanner)(const unsigned char *), unsigned char *ptr, int len, bufsize_t offset)
{
	bufsize_t res;

        if (ptr == NULL || offset >= len) {
          return 0;
        } else {
	  unsigned char lim = ptr[len];

	  ptr[len] = '\0';
	  res = scanner(ptr + offset);
	  ptr[len] = lim;
        }

	return res;
}

#line 38 "ext_scanners.re"


bufsize_t _scan_table_start(const unsigned char *p)
{
  const unsigned char *marker = NULL;
  const unsigned char *start = p;
  
#line 35 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ':
    case '|': goto yy3;
    case '-': goto yy4;
    case ':': goto yy5;
    default: goto yy1;
  }
yy1:
  ++p;
yy2:
#line 48 "ext_scanners.re"
  { return 0; }
#line 54 "ext_scanners.c"
yy3:
  yych = *(marker = ++p);
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy6;
    case '-': goto yy8;
    case ':': goto yy9;
    default: goto yy2;
  }
yy4:
  yych = *(marker = ++p);
  switch (yych) {
    case '\t':
    case '\n':
    case '\v':
    case '\f':
    case '\r':
    case ' ':
    case '|': goto yy11;
    case '-': goto yy8;
    case ':': goto yy10;
    default: goto yy2;
  }
yy5:
  yych = *(marker = ++p);
  switch (yych) {
    case '-': goto yy8;
    default: goto yy2;
  }
yy6:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy6;
    case '-': goto yy8;
    case ':': goto yy9;
    default: goto yy7;
  }
yy7:
  p = marker;
  goto yy2;
yy8:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ':
    case ':': goto yy10;
    case '\n': goto yy12;
    case '\r': goto yy13;
    case '-': goto yy8;
    case '|': goto yy14;
    default: goto yy7;
  }
yy9:
  yych = *++p;
  switch (yych) {
    case '-': goto yy8;
    default: goto yy7;
  }
yy10:
  yych = *++p;
yy11:
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy10;
    case '\n': goto yy12;
    case '\r': goto yy13;
    case '|': goto yy14;
    default: goto yy7;
  }
yy12:
  ++p;
#line 45 "ext_scanners.re"
  {
      return (bufsize_t)(p - start);
    }
#line 139 "ext_scanners.c"
yy13:
  yych = *++p;
  switch (yych) {
    case '\n': goto yy12;
    default: goto yy7;
  }
yy14:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy14;
    case '\n': goto yy12;
    case '\r': goto yy13;
    case '-': goto yy8;
    case ':': goto yy9;
    default: goto yy7;
  }
}
#line 49 "ext_scanners.re"

}

bufsize_t _scan_table_cell(const unsigned char *p)
{
  const unsigned char *marker = NULL;
  const unsigned char *start = p;
  
#line 169 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case '\n':
    case '\r':
    case '|': goto yy18;
    case '\\': goto yy19;
    default: goto yy16;
  }
yy16:
  yych = *++p;
  switch (yych) {
    case '\n':
    case '\r':
    case '|': goto yy17;
    case '\\': goto yy19;
    default: goto yy16;
  }
yy17:
#line 60 "ext_scanners.re"
  { return (bufsize_t)(p - start); }
#line 192 "ext_scanners.c"
yy18:
  ++p;
#line 61 "ext_scanners.re"
  { return 0; }
#line 197 "ext_scanners.c"
yy19:
  yych = *++p;
  switch (yych) {
    case '\n':
    case '\r': goto yy17;
    case '\\': goto yy19;
    default: goto yy16;
  }
}
#line 62 "ext_scanners.re"

}

bufsize_t _scan_table_cell_end(const unsigned char *p)
{
  const unsigned char *start = p;
  
#line 215 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case '|': goto yy22;
    default: goto yy21;
  }
yy21:
  ++p;
#line 70 "ext_scanners.re"
  { return 0; }
#line 227 "ext_scanners.c"
yy22:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy22;
    default: goto yy23;
  }
yy23:
#line 69 "ext_scanners.re"
  { return (bufsize_t)(p - start); }
#line 240 "ext_scanners.c"
}
#line 71 "ext_scanners.re"

}

bufsize_t _scan_table_row_end(const unsigned char *p)
{
  const unsigned char *marker = NULL;
  const unsigned char *start = p;
  
#line 251 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy27;
    case '\n': goto yy28;
    case '\r': goto yy29;
    default: goto yy25;
  }
yy25:
  ++p;
yy26:
#line 80 "ext_scanners.re"
  { return 0; }
#line 269 "ext_scanners.c"
yy27:
  yych = *(marker = ++p);
  switch (yych) {
    case '\t':
    case '\n':
    case '\v':
    case '\f':
    case '\r':
    case ' ': goto yy31;
    default: goto yy26;
  }
yy28:
  ++p;
#line 79 "ext_scanners.re"
  { return (bufsize_t)(p - start); }
#line 285 "ext_scanners.c"
yy29:
  yych = *++p;
  switch (yych) {
    case '\n': goto yy28;
    default: goto yy26;
  }
yy30:
  yych = *++p;
yy31:
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy30;
    case '\n': goto yy28;
    case '\r': goto yy33;
    default: goto yy32;
  }
yy32:
  p = marker;
  goto yy26;
yy33:
  yych = *++p;
  switch (yych) {
    case '\n': goto yy28;
    default: goto yy32;
  }
}
#line 81 "ext_scanners.re"

}

bufsize_t _scan_tasklist(const unsigned char *p)
{
  const unsigned char *marker = NULL;
  const unsigned char *start = p;
  
#line 323 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy37;
    case '*':
    case '+':
    case '-': goto yy38;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': goto yy39;
    default: goto yy35;
  }
yy35:
  ++p;
yy36:
#line 90 "ext_scanners.re"
  { return 0; }
#line 352 "ext_scanners.c"
yy37:
  yych = *(marker = ++p);
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy40;
    case '*':
    case '+':
    case '-': goto yy42;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': goto yy43;
    default: goto yy36;
  }
yy38:
  yych = *(marker = ++p);
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy44;
    default: goto yy36;
  }
yy39:
  yych = *(marker = ++p);
  switch (yych) {
    case '\n': goto yy36;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': goto yy46;
    default: goto yy42;
  }
yy40:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy40;
    case '*':
    case '+':
    case '-': goto yy42;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': goto yy43;
    default: goto yy41;
  }
yy41:
  p = marker;
  goto yy36;
yy42:
  yych = *++p;
  switch (yych) {
    case '[': goto yy41;
    default: goto yy45;
  }
yy43:
  yych = *++p;
  switch (yych) {
    case '\n': goto yy41;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': goto yy46;
    default: goto yy42;
  }
yy44:
  yych = *++p;
yy45:
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy44;
    case '[': goto yy47;
    default: goto yy41;
  }
yy46:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy44;
    case '\n': goto yy41;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': goto yy46;
    default: goto yy42;
  }
yy47:
  yych = *++p;
  switch (yych) {
    case ' ':
    case 'x': goto yy48;
    default: goto yy41;
  }
yy48:
  yych = *++p;
  switch (yych) {
    case ']': goto yy49;
    default: goto yy41;
  }
yy49:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy50;
    default: goto yy41;
  }
yy50:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy50;
    default: goto yy51;
  }
yy51:
#line 89 "ext_scanners.re"
  { return (bufsize_t)(p - start); }
#line 512 "ext_scanners.c"
}
#line 91 "ext_scanners.re"

}

bufsize_t _scan_open_spoiler_fence(const unsigned char *p)
{
  const unsigned char *marker = NULL;
  const unsigned char *start = p;
  
#line 523 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case ':': goto yy55;
    default: goto yy53;
  }
yy53:
  ++p;
yy54:
#line 103 "ext_scanners.re"
  { return 0; }
#line 536 "ext_scanners.c"
yy55:
  yych = *(marker = ++p);
  switch (yych) {
    case ':': goto yy56;
    default: goto yy54;
  }
yy56:
  yych = *++p;
  switch (yych) {
    case ':': goto yy58;
    default: goto yy57;
  }
yy57:
  p = marker;
  goto yy54;
yy58:
  yych = *++p;
  switch (yych) {
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy59;
    case ':': goto yy58;
    default: goto yy57;
  }
yy59:
  yych = *++p;
  switch (yych) {
    case 's': goto yy60;
    default: goto yy57;
  }
yy60:
  yych = *++p;
  switch (yych) {
    case 'p': goto yy61;
    default: goto yy57;
  }
yy61:
  yych = *++p;
  switch (yych) {
    case 'o': goto yy62;
    default: goto yy57;
  }
yy62:
  yych = *++p;
  switch (yych) {
    case 'i': goto yy63;
    default: goto yy57;
  }
yy63:
  yych = *++p;
  switch (yych) {
    case 'l': goto yy64;
    default: goto yy57;
  }
yy64:
  yych = *++p;
  switch (yych) {
    case 'e': goto yy65;
    default: goto yy57;
  }
yy65:
  yych = *++p;
  switch (yych) {
    case 'r': goto yy66;
    default: goto yy57;
  }
yy66:
  yych = *++p;
  switch (yych) {
    case 0x00: goto yy57;
    case '\t':
    case '\v':
    case '\f':
    case ' ': goto yy68;
    case '\n':
    case '\r':
      marker = p;
      goto yy69;
    default:
      marker = p;
      goto yy67;
  }
yy67:
  yych = *++p;
  switch (yych) {
    case 0x00: goto yy57;
    case '\n':
    case '\r': goto yy69;
    default: goto yy67;
  }
yy68:
  yych = *++p;
  switch (yych) {
    case 0x00: goto yy57;
    case '\n':
    case '\r':
      marker = p;
      goto yy69;
    default:
      marker = p;
      goto yy67;
  }
yy69:
  ++p;
  p = marker;
#line 99 "ext_scanners.re"
  { return (bufsize_t)(p - start); }
#line 648 "ext_scanners.c"
}
#line 104 "ext_scanners.re"

}

bufsize_t _scan_close_spoiler_fence(const unsigned char *p)
{
  const unsigned char *marker = NULL;
  const unsigned char *start = p;
  
#line 659 "ext_scanners.c"
{
  unsigned char yych;
  yych = *p;
  switch (yych) {
    case ':': goto yy73;
    default: goto yy71;
  }
yy71:
  ++p;
yy72:
#line 113 "ext_scanners.re"
  { return 0; }
#line 672 "ext_scanners.c"
yy73:
  yych = *(marker = ++p);
  switch (yych) {
    case ':': goto yy74;
    default: goto yy72;
  }
yy74:
  yych = *++p;
  switch (yych) {
    case ':': goto yy76;
    default: goto yy75;
  }
yy75:
  p = marker;
  goto yy72;
yy76:
  yych = *++p;
  switch (yych) {
    case '\t':
    case ' ':
      marker = p;
      goto yy77;
    case '\n':
    case '\r':
      marker = p;
      goto yy78;
    case ':': goto yy76;
    default: goto yy75;
  }
yy77:
  yych = *++p;
  switch (yych) {
    case '\t':
    case ' ': goto yy77;
    case '\n':
    case '\r': goto yy78;
    default: goto yy75;
  }
yy78:
  ++p;
  p = marker;
#line 112 "ext_scanners.re"
  { return (bufsize_t)(p - start); }
#line 716 "ext_scanners.c"
}
#line 114 "ext_scanners.re"

}

import sys
from fontTools.ttLib import TTFont

def main():
    if len(sys.argv) < 2:
        print("Usage: python decompose.py <font.ttf>")
        sys.exit(1)

    font_path = sys.argv[1]
    font = TTFont(font_path)
    glyf = font['glyf']
    count = 0

    # Iterate over all glyphs
    for glyph_name in glyf.keys():
        glyph = glyf[glyph_name]
        
        # We only care about composite glyphs (glyphs made of components)
        if glyph.isComposite():
            # Check if any of the components are THEMSELVES composites
            is_nested = False
            for component in glyph.components:
                # Look up the component glyph
                if glyf[component.glyphName].isComposite():
                    is_nested = True
                    break
            
            # If we found nesting, flatten this glyph into contours
            if is_nested:
                # expand(glyf) decomposes the components into raw contours
                glyph.expand(glyf)
                count += 1

    if count > 0:
        print(f"Decomposed {count} nested composite glyphs.")
        font.save(font_path)
    else:
        print("No nested components found.")

if __name__ == "__main__":
    main()
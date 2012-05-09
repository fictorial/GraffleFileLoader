# GraffleFileLoader

A loader of canvases, layers, and shapes from OmniGraffle files (.graffle).

Sure, OmniGraffle files are "just" a PLIST but there are many gotchas.  The main
benefit here is that it "normalizes" the data in the .graffle file by
expliciting adding in values OmniGraffle excludes; that is, values matching
defaults are not stored by OmniGraffle in .graffle files.
 
## OmniGraffle File Assumptions
 
To use, in OmniGraffle's document inspector, set the "File format options" to
"Save as flat file" and uncheck "Compress on disk". Set each canvas to use
"Ruler Units" of "pixels (px)" and a "Unit Scale" of "1 pt = 1 px".

Any "shaped graphic" should use a rectangle for its shape (and not say 
a star or checkmark). To simulate a circle or more generally an ellipse,
set the proper corner radius in the stroke inspector. This is mostly because
OmniGraffle does not expose the points of their custom shapes.

Note that a shape may contain various fill styles (solid, linear gradient,
radial gradient), stroke styles (line color, thickness, corner radius, end-cap
styles), text (RTF text, any font(s), alignment and placement (vertical alignment)),
images (path to image, clip/stretch to fill/tile), and shadows (fuzziness, color).
Thus, this isn't as limited as you might think.

However, to support more complex OmniGraffle-native shapes, select the shape, then 
'File > Export', current selection with no margin on transparent background
and PDF type, then 'File > Place Image...' and choose 'link to image file', 
choose your PDF, and delete the original shaped graphic.

Don't embed images in the .graffle document; link to them instead.
This means not dragging images into OmniGraffle but rather using 
"File > Place Image..."

If you plan on using this in an iOS project, be sure to bundle any linked
PDFs and embed any custom fonts.  Use the UIImage-PDF project to convert
PDFs into UIImage objects.

## Using this Code

    git clone ...
    git submodule init
    git submodule update
 
## Environment
 
Tested using files generated with OmniGraffle/5.3.6/GM-v138.33.

## Known Issues
 
Unsupported features include anyting unrelated to the bounds and styling of
rectangular shaped graphics and anything unrelated to canvases and layers.
This includes lines, magnets, actions/links, user data (Pro), etc.
 
Compression is not supported but will be at some point.

## Author

Brian Hammond (brian@fictorial.com)

## License

Copyright © 2012 Fictorial LLC.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


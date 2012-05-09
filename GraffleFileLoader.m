#import "GraffleFileLoader.h"
#import "OUIRTFReader.h"

NSArray *colorComponentsFromDictionary(NSDictionary *dict, NSArray *defaultColor) {
    if (!dict) {
        return defaultColor;
    }
    
    // RGB with optional alpha
    
    NSNumber *r = [dict objectForKey:@"r"];
    NSNumber *g = [dict objectForKey:@"g"];
    NSNumber *b = [dict objectForKey:@"b"];
    NSNumber *a = [dict objectForKey:@"a"];
    
    NSNumber *alpha = a ? a : [NSNumber numberWithFloat:1.0];
    
    if (r && g && b) {
        return [NSArray arrayWithObjects:r, g, b, alpha, nil];
    }
    
    // White with optional alpha
    
    NSNumber *w = [dict objectForKey:@"w"];
    
    if (w) {
        return [NSArray arrayWithObjects:w, w, w, alpha, nil];
    }
    
    return defaultColor;
}

// The default "Stroke Color" is black
// The default "Stroke Dash Pattern" is solid (0)
// The default "Corner Radius" is 0
// The default "Thickness" is 1 (stroke width)
// The default "Stroke End Type" is "Round"
// The default "Stroke Corner Type" is "Round"
//
// AFAICT the "Stroke Dash Patterns" are undocumented so I laboriously determined the patterns by 
// using a butt stroke on a line atop a 1-pixel grid.  *Sigh*
//
// Only a "Single Stroke" is supported not a "Double Stroke" since I don't know how to draw a double stroke

NSDictionary *normalizedStrokeDictionaryFromDictionary(NSDictionary *strokeDict) {
    NSArray *color = colorComponentsFromDictionary([strokeDict objectForKey:@"Color"],
                                                   [NSArray arrayWithObjects:
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:1], 
                                                    nil]);
    
    NSNumber *cornerRadius = [strokeDict objectForKey:@"CornerRadius"];
    if (!cornerRadius) {
        cornerRadius = [NSNumber numberWithFloat:0];
    }
    
    NSNumber *width = [strokeDict objectForKey:@"Width"];
    if (!width) {
        width = [NSNumber numberWithFloat:1];
    }
    
    // 0 = solid so this works if Pattern is not present (nil)
    NSUInteger dashPatternStyle = [[strokeDict objectForKey:@"Pattern"] unsignedIntegerValue];
    
    // Convert enumerated type to array of run-lengths for dash pattern.
    // See CGContextSetLineDash for details; also Quartz Demo.
    
    id dashPattern = [NSNull null];
    
    switch (dashPatternStyle) {
        case 0:   // solid ('a' in the OG stroke inspector)
            break;
            
        case 1:   // 'b'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:4],
                           nil];
            break;
            
        case 2:   // 'c'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:4],
                           nil];
            break;
            
        case 3:   // 'd'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:4],
                           nil];
            break;
            
        case 4:   // 'e'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 5:   // 'f'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 6:   // 'g'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 7:   // 'h'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 8:   // 'i'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 9:   // 'j'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:20],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 10:   // 'k'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:20],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:5],
                           nil];
            break;
            
        case 11:   // 'l'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:3],
                           nil];
            break;
            
        case 12:   // 'm'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:3],
                           nil];
            break;
            
        case 13:   // 'n'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:3],
                           nil];
            break;
            
        case 14:   // 'o'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:3],
                           nil];
            break;
            
        case 15:   // 'p'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:10],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:3],
                           nil];
            break;
            
        case 16:   // 'q'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:10],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:3],
                           nil];
            break;
            
        case 17:   // 'r'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:16],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 18:   // 's'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 19:   // 't'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:16],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 20:   // 'u'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:16],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 21:   // 'v'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:16],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:16],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 22:   // 'w'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:40],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 23:   // 'x'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:40],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:9],
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:9],
                           nil];
            break;
            
        case 24:   // 'y'
            dashPattern = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:2],
                           nil];
            break;
            
        default:
            NSLog(@"WARNING: unsupported dash pattern style %u; using solid.", dashPatternStyle);
            break;
    }
    
    NSNumber *capTypeValue = [strokeDict objectForKey:@"Cap"];
    NSUInteger capType = kGraffleStrokeCapRound;
    if (capTypeValue) {
        capType = [capTypeValue unsignedIntegerValue];
    }
    
    NSNumber *joinTypeValue = [strokeDict objectForKey:@"Join"];
    NSUInteger joinType = kGraffleStrokeJoinRound;
    if (joinTypeValue) {
        joinType = [joinTypeValue unsignedIntegerValue];
    }
    
    id disabledValue = [strokeDict objectForKey:@"Draws"]; 
    BOOL disabled = (disabledValue != nil && [disabledValue boolValue] == NO);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:disabled], @"disabled",
            color, @"color", 
            cornerRadius, @"cornerRadius",
            width, @"width",
            dashPattern, @"dashPattern",
            [NSNumber numberWithUnsignedInteger:capType], @"capType",
            [NSNumber numberWithUnsignedInteger:joinType], @"joinType",
            nil];
}

// Default "Fill Style" (FillType) is 0 or solid [2 is linear gradients; 3 radial gradients]
//
// For linear gradients, the start color is "Color" and the end is "GradientColor" with a
// default Color of white (not written to file in this case).
//
// A double-{linear,radial} gradient has type {2,3} but also has a "MiddleColor".
//
// GradientAngle is 90 for T-B; 270 for B-T; 225 for BR-TL; 135 for TR-BL;
// 45 for TL-BR; 0 for L-R; 180 for R-L. Only for linear gradients.
//
// Default GradientCenter is {0,0} and isn't written if left as default.
// Note: "gradient center (point) : Starting point of a radial gradient fill. 
//  (In a square from {-1,-1} to {1,1} so {0,0} is the center of the solid.)"
//
// Default MiddleFraction is 0.5. "For double linear and radial fills, this is
// the position of the blend color from 0 to 1."

NSDictionary *normalizedFillDictionaryFromDictionary(NSDictionary *fillDict) {    
    id typeValue = [fillDict objectForKey:@"FillType"];
    NSUInteger type = kGraffleFillSolid;
    if (typeValue) {
        type = [typeValue unsignedIntegerValue];
    }
    
    NSArray *whiteColor = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:1],
                           [NSNumber numberWithFloat:1],
                           [NSNumber numberWithFloat:1],
                           [NSNumber numberWithFloat:1],
                           nil];
    
    NSArray *startColor = colorComponentsFromDictionary([fillDict objectForKey:@"Color"], whiteColor);
    
    id middleColor = [NSNull null];
    id endColor = [NSNull null];
    
    CGFloat middleFraction = 0.5;
    
    if (type == kGraffleFillLinearGradient || 
        type == kGraffleFillRadialGradient) {
        
        id middleColorValue = [fillDict objectForKey:@"MiddleColor"];        
        if (middleColorValue != nil) {
            middleColor = colorComponentsFromDictionary(middleColorValue, whiteColor);
        }
        
        id endColorValue = [fillDict objectForKey:@"GradientColor"];        
        if (endColorValue != nil) {
            endColor = colorComponentsFromDictionary(endColorValue, whiteColor);
        }
        
        id middleFractionValue = [fillDict objectForKey:@"MiddleFraction"];
        if (middleFractionValue) {
            middleFraction = [middleFractionValue floatValue];
        }
        
        if (middleColor == [NSNull null]) {
            // Middle color is officially only specified for double-linear/radial gradients.
            // But it *is* used in OmniGraffle for single-linear/radial gradients. 
            // Thus, all linear/radial gradients in OG are effectively double-linear/radial gradients.
            // The implied middle color of a "single" linear/radial gradient is the average of 
            // the start and end colors.
            
            CGFloat middleColorComponents[4];
            
            for (int i = 0; i < 4; ++i) {
                middleColorComponents[i] = ([[startColor objectAtIndex:i] floatValue] + 
                                            [[endColor objectAtIndex:i] floatValue]) / 2.0;
            }
            
            middleColor = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:middleColorComponents[0]],
                           [NSNumber numberWithFloat:middleColorComponents[1]],
                           [NSNumber numberWithFloat:middleColorComponents[2]],
                           [NSNumber numberWithFloat:middleColorComponents[3]],
                           nil];
        }
    }
    
    CGFloat angle = 90.0;
    if (type == kGraffleFillLinearGradient) {
        id angleValue = [fillDict objectForKey:@"GradientAngle"];
        if (angleValue) {
            angle = [angleValue floatValue];
        }
    }
    
    CGPoint centerPoint = CGPointZero;
    if (type == kGraffleFillRadialGradient) {
        id gradientCenterValue = [fillDict objectForKey:@"GradientCenter"];
        if (gradientCenterValue != nil) {
            centerPoint = CGPointFromString(gradientCenterValue);
        }
    }    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInteger:type], @"type",
            startColor, @"startColor",
            middleColor, @"middleColor",
            endColor, @"endColor",
            [NSValue valueWithCGPoint:centerPoint], @"radialCenterPoint",  // for radial
            [NSNumber numberWithFloat:angle], @"linearAngle",              // for linear
            [NSNumber numberWithFloat:middleFraction], @"middleFraction",  // officially for double-linear/radial but used for single too
            nil];
}

// Default "Shadow Position" (ShadowVector) is {0,4} and isn't written if so.
// Default "Shadow Fuzziness" (Fuzziness) seems to be 7 in a range of [0,32].
// Default "Shadow Color" (Color) is 75%-transparent black.
// We only support "shadow immediately beneath this object" mode.

NSDictionary *normalizedShadowDictionaryFromDictionary(NSDictionary *shadowDict) {
    id disabledValue = [shadowDict objectForKey:@"Draws"]; 
    BOOL disabled = (disabledValue != nil && [disabledValue boolValue] == NO);
    
    id vectorValue = [shadowDict valueForKeyPath:@"ShadowVector"];
    static id defaultVectorValue = nil;
    if (!defaultVectorValue)
        defaultVectorValue = [NSValue valueWithCGSize:CGSizeMake(0, 4)];
    id vector = defaultVectorValue;
    if (vectorValue) {
        vector = [NSValue valueWithCGSize:CGSizeFromString(vectorValue)];
    }
    
    id fuzzinessValue = [shadowDict objectForKey:@"Fuzziness"];
    CGFloat fuzziness = 7.0;    
    if (fuzzinessValue) {
        fuzziness = [fuzzinessValue floatValue];
    }
    
    NSArray *color = colorComponentsFromDictionary([shadowDict objectForKey:@"Color"],
                                                   [NSArray arrayWithObjects:
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0.75],
                                                    nil]);
    
    if (!disabled) {
        id beneathValue = [shadowDict objectForKey:@"Beneath"];
        if (beneathValue && [beneathValue boolValue] == NO) {
            NSLog(@"WARNING: only 'shadow immediately beneath this object' mode is supported; overriding.");
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:disabled], @"disabled",
            vector, @"vector",
            [NSNumber numberWithFloat:fuzziness], @"fuzziness",
            color, @"color",
            nil];
}

// Default "ImageSizing" is 1 (stretch to fill); other values are 0 for natural size and 2 for tiled.
// Default "Scale" is 1.0.
// Default "Horizontal Offset" is 0%.
// Default "Vertical Offset" is 0%.
// Default "Opacity" is 100% (opaque).

NSDictionary *normalizedImageDictionaryFromDictionary(NSDictionary *imageDict) {
    id sizingTypeValue = [imageDict objectForKey:@"ImageSizing"];
    NSUInteger sizingType = kGraffleImageSizingStretchToFill;
    if (sizingTypeValue) {
        sizingType = [sizingTypeValue unsignedIntegerValue];
    }
    
    id scaleValue = [imageDict objectForKey:@"Scale"];
    CGFloat scale = 1.0;    
    if (scaleValue) {
        scale = [scaleValue floatValue];
    }
    
    id offsetValue = [imageDict objectForKey:@"Offset"];
    CGPoint offset = CGPointZero;    
    if (offsetValue) {
        offset = CGPointFromString(offsetValue);
    }
    
    id opacityValue = [imageDict objectForKey:@"Opacity"];
    CGFloat opacity = 1.0;    
    if (opacityValue) {
        opacity = [opacityValue floatValue];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInteger:sizingType], @"sizingType",
            [NSNumber numberWithFloat:scale], @"scale",
            [NSValue valueWithCGPoint:offset], @"offset",
            [NSNumber numberWithFloat:opacity], @"opacity",
            nil];
}

NSDictionary *normalizedStyleDictionaryFromDictionary(NSDictionary *styleDict) {
    NSDictionary *fillDict = normalizedFillDictionaryFromDictionary([styleDict objectForKey:@"fill"]);
    NSDictionary *strokeDict = normalizedStrokeDictionaryFromDictionary([styleDict objectForKey:@"stroke"]);
    NSDictionary *shadowDict = normalizedShadowDictionaryFromDictionary([styleDict objectForKey:@"shadow"]);
    NSDictionary *imageDict = normalizedImageDictionaryFromDictionary([styleDict objectForKey:@"image fill"]);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            fillDict, @"fill",
            strokeDict, @"stroke", 
            shadowDict, @"shadow",
            imageDict, @"image",
            nil];
}

// RTF support is not included on iOS so I extracted OmniGroup's RTF
// reader from their frameworks and use that to parse the RTF data
// into an attributed string.  *Sigh*

// Default horizontal alignment is center.
// Default vertical alignment is center.
// Default horizontal (side) padding is 5.
// Default vertical (top) padding is 5.
// Default relative area rect is (0,0,1,1) and represents percentages of the graphic
//   within which the text is rendered.
// Default text rotation is 0°
// Default text rotation type is absolute (vs relative to parent graphic) I think;
//   anyway we only support absolute mode

// Beyond that, we only support Kerning ON (default), wrap-to-shape ON,
// and clip-to-bounds. Hyphenation is not supported; it's just word-wrap.
// We also do not support Tracking and Leading (whatever they are)

NSDictionary *normalizedTextDictionaryFromDictionary(NSDictionary *textDict, NSDictionary *graphicDict) {
    NSString *rtfString = [textDict objectForKey:@"Text"];   
    NSAttributedString *attributedText = [OUIRTFReader parseRTFString:rtfString];
    NSString *plainText = [attributedText string];
    
    id alignmentValue = [textDict objectForKey:@"Align"];
    NSUInteger alignment = kGraffleTextAlignmentCenter;
    if (alignmentValue) {
        alignment = [alignmentValue unsignedIntegerValue];
    }
    
    id hpadValue = [textDict objectForKey:@"Pad"];
    NSUInteger hpad = 5;
    if (hpadValue) {
        hpad = [hpadValue unsignedIntegerValue];
    }
    
    id vpadValue = [textDict objectForKey:@"VerticalPad"];
    NSUInteger vpad = 5;
    if (vpadValue) {
        vpad = [vpadValue unsignedIntegerValue];
    }
    
    // The following are outside the text dictionary for some reason
    // - vertical alignment ("text placement") 
    // - text relative area
    // - text rotation angle in degrees
    // - font info
    
    id placementValue = [graphicDict objectForKey:@"TextPlacement"];
    NSUInteger placement = kGraffleTextPlacementMiddle;
    if (placementValue) {
        placement = [placementValue unsignedIntegerValue];
    }
    
    id relativeAreaRectValue = [graphicDict objectForKey:@"TextRelativeArea"];
    CGRect relativeAreaRect = CGRectMake(0, 0, 1, 1); // percentages
    if (relativeAreaRectValue) {
        relativeAreaRect = CGRectFromString(relativeAreaRectValue);
    }
    
    id angleValue = [graphicDict objectForKey:@"TextRotation"];
    CGFloat angle = 0.0;
    if (angleValue) {
        angle = [angleValue floatValue];
    }
    
    id fontDict = [graphicDict objectForKey:@"FontInfo"];
    
    NSArray *color = colorComponentsFromDictionary([fontDict objectForKey:@"Color"],
                                                   [NSArray arrayWithObjects:
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:0],
                                                    [NSNumber numberWithFloat:1],
                                                    nil]);
    
    id fontSizeValue = [fontDict objectForKey:@"Size"];
    CGFloat fontSize = 13;  // arbitrary
    if (fontSizeValue) {
        fontSize = [fontSizeValue floatValue];
    }
    
    id fontName = [fontDict objectForKey:@"Font"];
    if (!fontName) {
        fontName = @"Helvetica";
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            plainText, @"string",
            attributedText, @"attributedString",
            color, @"color",
            [NSNumber numberWithUnsignedInteger:alignment], @"alignment",
            [NSNumber numberWithUnsignedInteger:placement], @"placement",
            [NSNumber numberWithUnsignedInteger:hpad], @"horizontalPadding",
            [NSNumber numberWithUnsignedInteger:vpad], @"verticalPadding",
            [NSNumber numberWithFloat:angle], @"angle",
            [NSValue valueWithCGRect:relativeAreaRect], @"relativeArea",
            [NSNumber numberWithFloat:fontSize], @"fontSize",
            fontName, @"fontName",
            nil];
}

// Returns NSDictionary for single graphic
// Returns NSArray of NSDictionary for a group of graphics

id normalizedGraphicDictionaryFromGraphic(id graphicDict, NSDictionary *images) {
    NSString *className = [graphicDict objectForKey:@"Class"];
    
    if ([className isEqualToString:@"Group"]) {
        NSArray *inGroupedGraphics = [graphicDict objectForKey:@"Graphics"];
        NSMutableArray *outGroupedGraphics = [NSMutableArray arrayWithCapacity:inGroupedGraphics.count];
        for (id inGraphic in inGroupedGraphics) {
            id outGraphic = normalizedGraphicDictionaryFromGraphic(inGraphic, images);
            [outGroupedGraphics addObject:outGraphic];
        }
        return outGroupedGraphics;
    }
    
    if ([className isEqualToString:@"ShapedGraphic"]) {
        NSString *shapeType = [graphicDict objectForKey:@"Shape"];
        
        if ([shapeType isEqualToString:@"Rectangle"] == NO) {
            NSLog(@"WARNING: unsupported shape '%@'. Use rectangle or export this shaped graphic to PDF and replace in your document via: 1. Select the shaped graphic 2. 'File > Export' 3. Current selection w/ transparent background and no margin 4. 'File > Place Image...' 5. select 'Link to image file' 6. choose your PDF", shapeType);
        }
    } else if ([className isEqualToString:@"SolidGraphic"]) {
        // nop
    } else {
        NSLog(@"WARNING: unsupported class '%@'; only Group, ShapedGraphic, and SolidGraphic are supported.", className);
    }
    
    CGRect frame = CGRectFromString([graphicDict objectForKey:@"Bounds"]);    
    
    id imageID = [graphicDict objectForKey:@"ImageID"];
    id imagePath = [NSNull null];    
    if (imageID) {
        imagePath = [images objectForKey:[NSString stringWithFormat:@"%u", [imageID unsignedIntegerValue]]];        
        if (!imagePath) {
            NSLog(@"WARNING: image for imageID %u not found.", [imageID unsignedIntegerValue]);
            imagePath = [NSNull null];
        }
        
        NSString *fileExtension = [[imagePath pathExtension] uppercaseString];
        
        if ([fileExtension isEqualToString:@"PDF"] == NO &&
            [fileExtension isEqualToString:@"PNG"] == NO &&
            [fileExtension isEqualToString:@"JPG"] == NO) {
            NSLog(@"WARNING: image type %@ unsupported. Use PDF/PNG/JPG", fileExtension);
            imagePath = [NSNull null];
        }
    }
    
    id styleDict = normalizedStyleDictionaryFromDictionary([graphicDict objectForKey:@"Style"]);
    
    id textDict = [graphicDict objectForKey:@"Text"];
    if (textDict) { 
        textDict = normalizedTextDictionaryFromDictionary(textDict, graphicDict);
    } else {
        textDict = [NSNull null];
    }
    
    id layerIndexValue = [graphicDict objectForKey:@"Layer"];
    NSUInteger layerIndex = 0;
    if (layerIndexValue) {
        layerIndex = [layerIndexValue unsignedIntegerValue];
    }
    
    // TODO actions/links
    
    /*
     
     Open a URL:
     Link = { url = "a URL"}
     
     Open a File:
     Link = {fileReference = {path = "fileName"}}
     
     Jump to another canvas (other types unsupported):
     Link = {documentJump = {Type = 6; Worksheet = <INDEX>}};
     
     Show/hide layers:
     Link = {
     layersActionLink = {
     ActionItems = (
     {Layer = <INDEX>; Type = 1;}   Types: 0=None, 1=Show, 2=Hide, 3=Toggle
     );
     Worksheet = 0;
     };
     };
     
     */
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInteger:layerIndex], @"layerIndex",
            [NSValue valueWithCGRect:frame], @"bounds",
            imagePath, @"imagePath",
            styleDict, @"style",
            textDict, @"text",
            nil];
}

NSDictionary *normalizedLayerDictionaryFromDictionary(NSDictionary *layerDict) {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [layerDict objectForKey:@"Name"], @"name",
            [layerDict objectForKey:@"View"], @"visible",
            [NSMutableArray array], @"graphicIndexes",
            nil];
}

NSDictionary *loadGraffleFile(NSString *fileBaseName) {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileBaseName ofType:@"graffle"];
    NSDictionary *inDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //    NSLog(@"%@", inDict);
    
    NSMutableDictionary *outDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [inDict objectForKey:@"Creator"], @"author",
                                    [inDict objectForKey:@"ModificationDate"], @"lastModified",
                                    nil];
    
    NSArray *inCanvases = [inDict objectForKey:@"Sheets"];
    if (!inCanvases) {
        // OG merges a doc with one canvas with the root of the PLIST
        inCanvases = [NSArray arrayWithObject:inDict];
    }
    
    NSMutableArray *outCanvases = [NSMutableArray arrayWithCapacity:inCanvases.count];
    
    for (NSDictionary *inCanvas in inCanvases) {
        NSMutableDictionary *outCanvas = [NSMutableDictionary dictionary];
        
        [outCanvas setObject:[inCanvas objectForKey:@"UniqueID"] forKey:@"canvasID"];  // TODO assuming only need this for actions
        [outCanvas setObject:[inCanvas objectForKey:@"SheetTitle"] forKey:@"name"];
        [outCanvas setObject:[NSValue valueWithCGSize:CGSizeFromString([inCanvas objectForKey:@"CanvasSize"])] forKey:@"size"];
        
        NSString *displayScale = [inCanvas objectForKey:@"DisplayScale"];
        if ([displayScale isEqualToString:@"1 pt = 1 px"] == NO) {
            NSLog(@"WARNING: only canvases with Unit Scale of '1 pt = 1 px' are supported");
        }
        
        id inImages = [inCanvas objectForKey:@"Images"];
        NSMutableDictionary *outImages = [NSMutableDictionary dictionary];
        for (NSDictionary *imageDict in inImages) {
            NSString *filePath = [imageDict valueForKeyPath:@"FileReference.path"];
            NSString *fileName = [filePath lastPathComponent];
            NSString *bundledFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];            
            if (!bundledFilePath) {
                NSLog(@"WARNING: %@ is not bundled with this project (as %@); consider adding it.", filePath, fileName);
            } else {
                [outImages setObject:bundledFilePath forKey:[imageDict objectForKey:@"ID"]];
            }
        }
        
        NSArray *inLayers = [inCanvas objectForKey:@"Layers"];
        NSMutableArray *outLayers = [NSMutableArray arrayWithCapacity:inLayers.count];
        for (NSDictionary *inLayerDict in inLayers) {
            NSMutableDictionary *outLayerDict = [[normalizedLayerDictionaryFromDictionary(inLayerDict) mutableCopy] autorelease];
            [outLayers addObject:outLayerDict];
        }
        [outCanvas setObject:outLayers forKey:@"layers"];
        
        id bgDict = [inCanvas objectForKey:@"BackgroundGraphic"];
        [outCanvas setObject:normalizedGraphicDictionaryFromGraphic(bgDict, outImages) forKey:@"background"];
        
        // Z-order is front to back
        
        NSArray *inGraphics = [inCanvas objectForKey:@"GraphicsList"];
        NSMutableArray *outGraphics = [NSMutableArray arrayWithCapacity:inGraphics.count];
        NSUInteger index = 0;
        for (id graphic in inGraphics) {
            id normalizedGraphic = normalizedGraphicDictionaryFromGraphic(graphic, outImages);
            [outGraphics addObject:normalizedGraphic];
            
            // Add index into canvas' graphics list in the target layer for this graphic.
            
            id targetObject = normalizedGraphic;
            if ([normalizedGraphic isKindOfClass:[NSArray class]]) {
                // Groups don't have a Layer property so peek into first graphic of group for such.
                // All graphics in the group will be in the same layer.
                targetObject = [normalizedGraphic objectAtIndex:0];
            }
            NSUInteger layerIndex = [[targetObject objectForKey:@"layerIndex"] unsignedIntegerValue];
            NSMutableDictionary *layerDict = [outLayers objectAtIndex:layerIndex];
            [[layerDict objectForKey:@"graphicIndexes"] addObject:[NSNumber numberWithUnsignedInteger:index]];
            
            ++index;
        }
        [outCanvas setObject:outGraphics forKey:@"graphics"];
        
        [outCanvases addObject:outCanvas];
    }
    
    [outDict setObject:outCanvases forKey:@"canvases"];
    
    return outDict;
}
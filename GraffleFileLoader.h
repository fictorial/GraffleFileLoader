#import <Foundation/Foundation.h>

enum {
    kGraffleFillSolid,
    kGraffleFillLinearGradient = 2,
    kGraffleFillRadialGradient
};

enum {
    kGraffleStrokeCapButt,
    kGraffleStrokeCapRound,
    kGraffleStrokeCapSquare
};

enum {
    kGraffleStrokeJoinMiter,
    kGraffleStrokeJoinRound,
    kGraffleStrokeJoinBevel
};

enum {
    kGraffleTextAlignmentLeft,
    kGraffleTextAlignmentCenter,
    kGraffleTextAlignmentRight
};

enum {
    kGraffleTextPlacementTop,
    kGraffleTextPlacementMiddle,
    kGraffleTextPlacementBottom
};

enum {
    kGraffleImageSizingNaturalSize,
    kGraffleImageSizingStretchToFill,
    kGraffleImageSizingTile
};

NSDictionary *loadGraffleFile(NSString *fileBaseName);

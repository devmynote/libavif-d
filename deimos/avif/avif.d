module avif.avif;

// Copyright 2019 Joe Drago. All rights reserved.
// SPDX-License-Identifier: BSD-2-Clause

extern (C):

// ---------------------------------------------------------------------------
// Export macros

// AVIF_BUILDING_SHARED_LIBS should only be defined when libavif is being built
// as a shared library.
// AVIF_DLL should be defined if libavif is a shared library. If you are using
// libavif as a CMake dependency, through a CMake package config file or through
// pkg-config, this is defined automatically.
//
// Here's what AVIF_API will be defined as in shared build:
// |       |        Windows        |                  Unix                  |
// | Build | __declspec(dllexport) | __attribute__((visibility("default"))) |
// |  Use  | __declspec(dllimport) |                                        |
//
// For static build, AVIF_API is always defined as nothing.


// ---------------------------------------------------------------------------
// Constants

// AVIF_VERSION_DEVEL should always be 0 for official releases / version tags,
// and non-zero during development of the next release. This should allow for
// downstream projects to do greater-than preprocessor checks on AVIF_VERSION
// to leverage in-development code without breaking their stable builds.
enum AVIF_VERSION_MAJOR = 1;
enum AVIF_VERSION_MINOR = 0;
enum AVIF_VERSION_PATCH = 3;
enum AVIF_VERSION_DEVEL = 0;
enum AVIF_VERSION = 
    ((AVIF_VERSION_MAJOR * 1000000) + (AVIF_VERSION_MINOR * 10000) + (AVIF_VERSION_PATCH * 100) + AVIF_VERSION_DEVEL);

alias avifBool = int;
enum AVIF_TRUE = 1;
enum AVIF_FALSE = 0;

enum AVIF_DIAGNOSTICS_ERROR_BUFFER_SIZE = 256;

// A reasonable default for maximum image size (in pixel count) to avoid out-of-memory errors or
// integer overflow in (32-bit) int or unsigned int arithmetic operations.
enum AVIF_DEFAULT_IMAGE_SIZE_LIMIT = (16384 * 16384);

// A reasonable default for maximum image dimension (width or height).
enum AVIF_DEFAULT_IMAGE_DIMENSION_LIMIT = 32768;

// a 12 hour AVIF image sequence, running at 60 fps (a basic sanity check as this is quite ridiculous)
enum AVIF_DEFAULT_IMAGE_COUNT_LIMIT = (12 * 3600 * 60);

enum AVIF_QUALITY_DEFAULT = -1;
enum AVIF_QUALITY_LOSSLESS = 100;
enum AVIF_QUALITY_WORST = 0;
enum AVIF_QUALITY_BEST = 100;

enum AVIF_QUANTIZER_LOSSLESS = 0;
enum AVIF_QUANTIZER_BEST_QUALITY = 0;
enum AVIF_QUANTIZER_WORST_QUALITY = 63;

enum AVIF_PLANE_COUNT_YUV = 3;

enum AVIF_SPEED_DEFAULT = -1;
enum AVIF_SPEED_SLOWEST = 0;
enum AVIF_SPEED_FASTEST = 10;

// This value is used to indicate that an animated AVIF file has to be repeated infinitely.
enum AVIF_REPETITION_COUNT_INFINITE = -1;
// This value is used if an animated AVIF file does not have repetitions specified using an EditList box. Applications can choose
// to handle this case however they want.
enum AVIF_REPETITION_COUNT_UNKNOWN = -2;

// The number of spatial layers in AV1, with spatial_id = 0..3.
enum AVIF_MAX_AV1_LAYER_COUNT = 4;

enum avifPlanesFlag
{
    AVIF_PLANES_YUV = (1 << 0),
    AVIF_PLANES_A = (1 << 1),

    AVIF_PLANES_ALL = 0xff
}

alias AVIF_PLANES_YUV = avifPlanesFlag.AVIF_PLANES_YUV;
alias AVIF_PLANES_A = avifPlanesFlag.AVIF_PLANES_A;
alias AVIF_PLANES_ALL = avifPlanesFlag.AVIF_PLANES_ALL;

alias avifPlanesFlags = uint;

enum avifChannelIndex
{
    // These can be used as the index for the yuvPlanes and yuvRowBytes arrays in avifImage.
    AVIF_CHAN_Y = 0,
    AVIF_CHAN_U = 1,
    AVIF_CHAN_V = 2,

    // This may not be used in yuvPlanes and yuvRowBytes, but is available for use with avifImagePlane().
    AVIF_CHAN_A = 3
}

alias AVIF_CHAN_Y = avifChannelIndex.AVIF_CHAN_Y;
alias AVIF_CHAN_U = avifChannelIndex.AVIF_CHAN_U;
alias AVIF_CHAN_V = avifChannelIndex.AVIF_CHAN_V;
alias AVIF_CHAN_A = avifChannelIndex.AVIF_CHAN_A;

// ---------------------------------------------------------------------------
// Version

const(char)* avifVersion();
void avifCodecVersions(char* outBuffer);
uint avifLibYUVVersion(); // returns 0 if libavif wasn't compiled with libyuv support

// ---------------------------------------------------------------------------
// Memory management

// NOTE: On memory allocation failure, the current implementation of avifAlloc() calls abort(),
// but in a future release it may return NULL. To be future-proof, callers should check for a NULL
// return value.
void* avifAlloc(size_t size);
void avifFree(void* p);

// ---------------------------------------------------------------------------
// avifResult

enum avifResult
{
    AVIF_RESULT_OK = 0,
    AVIF_RESULT_UNKNOWN_ERROR = 1,
    AVIF_RESULT_INVALID_FTYP = 2,
    AVIF_RESULT_NO_CONTENT = 3,
    AVIF_RESULT_NO_YUV_FORMAT_SELECTED = 4,
    AVIF_RESULT_REFORMAT_FAILED = 5,
    AVIF_RESULT_UNSUPPORTED_DEPTH = 6,
    AVIF_RESULT_ENCODE_COLOR_FAILED = 7,
    AVIF_RESULT_ENCODE_ALPHA_FAILED = 8,
    AVIF_RESULT_BMFF_PARSE_FAILED = 9,
    AVIF_RESULT_MISSING_IMAGE_ITEM = 10,
    AVIF_RESULT_DECODE_COLOR_FAILED = 11,
    AVIF_RESULT_DECODE_ALPHA_FAILED = 12,
    AVIF_RESULT_COLOR_ALPHA_SIZE_MISMATCH = 13,
    AVIF_RESULT_ISPE_SIZE_MISMATCH = 14,
    AVIF_RESULT_NO_CODEC_AVAILABLE = 15,
    AVIF_RESULT_NO_IMAGES_REMAINING = 16,
    AVIF_RESULT_INVALID_EXIF_PAYLOAD = 17,
    AVIF_RESULT_INVALID_IMAGE_GRID = 18,
    AVIF_RESULT_INVALID_CODEC_SPECIFIC_OPTION = 19,
    AVIF_RESULT_TRUNCATED_DATA = 20,
    AVIF_RESULT_IO_NOT_SET = 21, // the avifIO field of avifDecoder is not set
    AVIF_RESULT_IO_ERROR = 22,
    AVIF_RESULT_WAITING_ON_IO = 23, // similar to EAGAIN/EWOULDBLOCK, this means the avifIO doesn't have necessary data available yet
    AVIF_RESULT_INVALID_ARGUMENT = 24, // an argument passed into this function is invalid
    AVIF_RESULT_NOT_IMPLEMENTED = 25,  // a requested code path is not (yet) implemented
    AVIF_RESULT_OUT_OF_MEMORY = 26,
    AVIF_RESULT_CANNOT_CHANGE_SETTING = 27, // a setting that can't change is changed during encoding
    AVIF_RESULT_INCOMPATIBLE_IMAGE = 28,    // the image is incompatible with already encoded images

    // Kept for backward compatibility; please use the symbols above instead.
    AVIF_RESULT_NO_AV1_ITEMS_FOUND = AVIF_RESULT_MISSING_IMAGE_ITEM
}

alias AVIF_RESULT_OK = avifResult.AVIF_RESULT_OK;
alias AVIF_RESULT_UNKNOWN_ERROR = avifResult.AVIF_RESULT_UNKNOWN_ERROR;
alias AVIF_RESULT_INVALID_FTYP = avifResult.AVIF_RESULT_INVALID_FTYP;
alias AVIF_RESULT_NO_CONTENT = avifResult.AVIF_RESULT_NO_CONTENT;
alias AVIF_RESULT_NO_YUV_FORMAT_SELECTED = avifResult.AVIF_RESULT_NO_YUV_FORMAT_SELECTED;
alias AVIF_RESULT_REFORMAT_FAILED = avifResult.AVIF_RESULT_REFORMAT_FAILED;
alias AVIF_RESULT_UNSUPPORTED_DEPTH = avifResult.AVIF_RESULT_UNSUPPORTED_DEPTH;
alias AVIF_RESULT_ENCODE_COLOR_FAILED = avifResult.AVIF_RESULT_ENCODE_COLOR_FAILED;
alias AVIF_RESULT_ENCODE_ALPHA_FAILED = avifResult.AVIF_RESULT_ENCODE_ALPHA_FAILED;
alias AVIF_RESULT_BMFF_PARSE_FAILED = avifResult.AVIF_RESULT_BMFF_PARSE_FAILED;
alias AVIF_RESULT_MISSING_IMAGE_ITEM = avifResult.AVIF_RESULT_MISSING_IMAGE_ITEM;
alias AVIF_RESULT_DECODE_COLOR_FAILED = avifResult.AVIF_RESULT_DECODE_COLOR_FAILED;
alias AVIF_RESULT_DECODE_ALPHA_FAILED = avifResult.AVIF_RESULT_DECODE_ALPHA_FAILED;
alias AVIF_RESULT_COLOR_ALPHA_SIZE_MISMATCH = avifResult.AVIF_RESULT_COLOR_ALPHA_SIZE_MISMATCH;
alias AVIF_RESULT_ISPE_SIZE_MISMATCH = avifResult.AVIF_RESULT_ISPE_SIZE_MISMATCH;
alias AVIF_RESULT_NO_CODEC_AVAILABLE = avifResult.AVIF_RESULT_NO_CODEC_AVAILABLE;
alias AVIF_RESULT_NO_IMAGES_REMAINING = avifResult.AVIF_RESULT_NO_IMAGES_REMAINING;
alias AVIF_RESULT_INVALID_EXIF_PAYLOAD = avifResult.AVIF_RESULT_INVALID_EXIF_PAYLOAD;
alias AVIF_RESULT_INVALID_IMAGE_GRID = avifResult.AVIF_RESULT_INVALID_IMAGE_GRID;
alias AVIF_RESULT_INVALID_CODEC_SPECIFIC_OPTION = avifResult.AVIF_RESULT_INVALID_CODEC_SPECIFIC_OPTION;
alias AVIF_RESULT_TRUNCATED_DATA = avifResult.AVIF_RESULT_TRUNCATED_DATA;
alias AVIF_RESULT_IO_NOT_SET = avifResult.AVIF_RESULT_IO_NOT_SET;
alias AVIF_RESULT_IO_ERROR = avifResult.AVIF_RESULT_IO_ERROR;
alias AVIF_RESULT_WAITING_ON_IO = avifResult.AVIF_RESULT_WAITING_ON_IO;
alias AVIF_RESULT_INVALID_ARGUMENT = avifResult.AVIF_RESULT_INVALID_ARGUMENT;
alias AVIF_RESULT_NOT_IMPLEMENTED = avifResult.AVIF_RESULT_NOT_IMPLEMENTED;
alias AVIF_RESULT_OUT_OF_MEMORY = avifResult.AVIF_RESULT_OUT_OF_MEMORY;
alias AVIF_RESULT_CANNOT_CHANGE_SETTING = avifResult.AVIF_RESULT_CANNOT_CHANGE_SETTING;
alias AVIF_RESULT_INCOMPATIBLE_IMAGE = avifResult.AVIF_RESULT_INCOMPATIBLE_IMAGE;
alias AVIF_RESULT_NO_AV1_ITEMS_FOUND = avifResult.AVIF_RESULT_NO_AV1_ITEMS_FOUND;

const(char)* avifResultToString(avifResult result);

// ---------------------------------------------------------------------------
// avifROData/avifRWData: Generic raw memory storage

struct avifROData
{
    const(ubyte)* data;
    size_t size;
}

// Note: Use avifRWDataFree() if any avif*() function populates one of these.

struct avifRWData
{
    ubyte* data;
    size_t size;
}

// clang-format off
// Initialize avifROData/avifRWData on the stack with this
// #define AVIF_DATA_EMPTY { NULL, 0 }
// clang-format on

// The avifRWData input must be zero-initialized before being manipulated with these functions.
// If AVIF_RESULT_OUT_OF_MEMORY is returned, raw is left unchanged.
avifResult avifRWDataRealloc(avifRWData* raw, size_t newSize);
avifResult avifRWDataSet(avifRWData* raw, const(ubyte)* data, size_t len);
void avifRWDataFree(avifRWData* raw);

// ---------------------------------------------------------------------------
// Metadata

// Validates the first bytes of the Exif payload and finds the TIFF header offset (up to UINT32_MAX).
avifResult avifGetExifTiffHeaderOffset(const(ubyte)* exif, size_t exifSize, size_t* offset);
// Returns the offset to the Exif 8-bit orientation value and AVIF_RESULT_OK, or an error.
// If the offset is set to exifSize, there was no parsing error but no orientation tag was found.
avifResult avifGetExifOrientationOffset(const(ubyte)* exif, size_t exifSize, size_t* offset);

// ---------------------------------------------------------------------------
// avifPixelFormat
//
// Note to libavif maintainers: The lookup tables in avifImageYUVToRGBLibYUV
// rely on the ordering of this enum values for their correctness. So changing
// the values in this enum will require auditing avifImageYUVToRGBLibYUV for
// correctness.
enum avifPixelFormat
{
    // No YUV pixels are present. Alpha plane can still be present.
    AVIF_PIXEL_FORMAT_NONE = 0,

    AVIF_PIXEL_FORMAT_YUV444 = 1,
    AVIF_PIXEL_FORMAT_YUV422 = 2,
    AVIF_PIXEL_FORMAT_YUV420 = 3,
    AVIF_PIXEL_FORMAT_YUV400 = 4,
    AVIF_PIXEL_FORMAT_COUNT = 5
}

alias AVIF_PIXEL_FORMAT_NONE = avifPixelFormat.AVIF_PIXEL_FORMAT_NONE;
alias AVIF_PIXEL_FORMAT_YUV444 = avifPixelFormat.AVIF_PIXEL_FORMAT_YUV444;
alias AVIF_PIXEL_FORMAT_YUV422 = avifPixelFormat.AVIF_PIXEL_FORMAT_YUV422;
alias AVIF_PIXEL_FORMAT_YUV420 = avifPixelFormat.AVIF_PIXEL_FORMAT_YUV420;
alias AVIF_PIXEL_FORMAT_YUV400 = avifPixelFormat.AVIF_PIXEL_FORMAT_YUV400;
alias AVIF_PIXEL_FORMAT_COUNT = avifPixelFormat.AVIF_PIXEL_FORMAT_COUNT;

const(char)* avifPixelFormatToString(avifPixelFormat format);

struct avifPixelFormatInfo
{
    avifBool monochrome;
    int chromaShiftX;
    int chromaShiftY;
}

// Returns the avifPixelFormatInfo depending on the avifPixelFormat.
// When monochrome is AVIF_TRUE, chromaShiftX and chromaShiftY are set to 1 according to the AV1 specification but they should be ignored.
//
// Note: This function implements the second table on page 119 of the AV1 specification version 1.0.0 with Errata 1.
// For monochrome 4:0:0, subsampling_x and subsampling are specified as 1 to allow
// an AV1 implementation that only supports profile 0 to hardcode subsampling_x and subsampling_y to 1.
void avifGetPixelFormatInfo(avifPixelFormat format, avifPixelFormatInfo* info);

// ---------------------------------------------------------------------------
// avifChromaSamplePosition

enum avifChromaSamplePosition
{
    AVIF_CHROMA_SAMPLE_POSITION_UNKNOWN = 0,
    AVIF_CHROMA_SAMPLE_POSITION_VERTICAL = 1,
    AVIF_CHROMA_SAMPLE_POSITION_COLOCATED = 2
}

alias AVIF_CHROMA_SAMPLE_POSITION_UNKNOWN = avifChromaSamplePosition.AVIF_CHROMA_SAMPLE_POSITION_UNKNOWN;
alias AVIF_CHROMA_SAMPLE_POSITION_VERTICAL = avifChromaSamplePosition.AVIF_CHROMA_SAMPLE_POSITION_VERTICAL;
alias AVIF_CHROMA_SAMPLE_POSITION_COLOCATED = avifChromaSamplePosition.AVIF_CHROMA_SAMPLE_POSITION_COLOCATED;

// ---------------------------------------------------------------------------
// avifRange

enum avifRange
{
    AVIF_RANGE_LIMITED = 0,
    AVIF_RANGE_FULL = 1
}

alias AVIF_RANGE_LIMITED = avifRange.AVIF_RANGE_LIMITED;
alias AVIF_RANGE_FULL = avifRange.AVIF_RANGE_FULL;

// ---------------------------------------------------------------------------
// CICP enums - https://www.itu.int/rec/T-REC-H.273-201612-S/en

enum
{
    // This is actually reserved, but libavif uses it as a sentinel value.
    AVIF_COLOR_PRIMARIES_UNKNOWN = 0,

    AVIF_COLOR_PRIMARIES_BT709 = 1,
    AVIF_COLOR_PRIMARIES_IEC61966_2_4 = 1,
    AVIF_COLOR_PRIMARIES_UNSPECIFIED = 2,
    AVIF_COLOR_PRIMARIES_BT470M = 4,
    AVIF_COLOR_PRIMARIES_BT470BG = 5,
    AVIF_COLOR_PRIMARIES_BT601 = 6,
    AVIF_COLOR_PRIMARIES_SMPTE240 = 7,
    AVIF_COLOR_PRIMARIES_GENERIC_FILM = 8,
    AVIF_COLOR_PRIMARIES_BT2020 = 9,
    AVIF_COLOR_PRIMARIES_XYZ = 10,
    AVIF_COLOR_PRIMARIES_SMPTE431 = 11,
    AVIF_COLOR_PRIMARIES_SMPTE432 = 12, // DCI P3
    AVIF_COLOR_PRIMARIES_EBU3213 = 22
}

alias avifColorPrimaries = ushort; // AVIF_COLOR_PRIMARIES_*

// outPrimaries: rX, rY, gX, gY, bX, bY, wX, wY
void avifColorPrimariesGetValues(avifColorPrimaries acp, float* outPrimaries);
avifColorPrimaries avifColorPrimariesFind(const(float*) inPrimaries, const(char*)* outName);

enum
{
    // This is actually reserved, but libavif uses it as a sentinel value.
    AVIF_TRANSFER_CHARACTERISTICS_UNKNOWN = 0,

    AVIF_TRANSFER_CHARACTERISTICS_BT709 = 1,
    AVIF_TRANSFER_CHARACTERISTICS_UNSPECIFIED = 2,
    AVIF_TRANSFER_CHARACTERISTICS_BT470M = 4,  // 2.2 gamma
    AVIF_TRANSFER_CHARACTERISTICS_BT470BG = 5, // 2.8 gamma
    AVIF_TRANSFER_CHARACTERISTICS_BT601 = 6,
    AVIF_TRANSFER_CHARACTERISTICS_SMPTE240 = 7,
    AVIF_TRANSFER_CHARACTERISTICS_LINEAR = 8,
    AVIF_TRANSFER_CHARACTERISTICS_LOG100 = 9,
    AVIF_TRANSFER_CHARACTERISTICS_LOG100_SQRT10 = 10,
    AVIF_TRANSFER_CHARACTERISTICS_IEC61966 = 11,
    AVIF_TRANSFER_CHARACTERISTICS_BT1361 = 12,
    AVIF_TRANSFER_CHARACTERISTICS_SRGB = 13,
    AVIF_TRANSFER_CHARACTERISTICS_BT2020_10BIT = 14,
    AVIF_TRANSFER_CHARACTERISTICS_BT2020_12BIT = 15,
    AVIF_TRANSFER_CHARACTERISTICS_SMPTE2084 = 16, // PQ
    AVIF_TRANSFER_CHARACTERISTICS_SMPTE428 = 17,
    AVIF_TRANSFER_CHARACTERISTICS_HLG = 18
}

alias avifTransferCharacteristics = ushort; // AVIF_TRANSFER_CHARACTERISTICS_*

// If the given transfer characteristics can be expressed with a simple gamma value, sets 'gamma'
// to that value and returns AVIF_RESULT_OK. Returns an error otherwise.
avifResult avifTransferCharacteristicsGetGamma(avifTransferCharacteristics atc, float* gamma);
avifTransferCharacteristics avifTransferCharacteristicsFindByGamma(float gamma);

enum
{
    AVIF_MATRIX_COEFFICIENTS_IDENTITY = 0,
    AVIF_MATRIX_COEFFICIENTS_BT709 = 1,
    AVIF_MATRIX_COEFFICIENTS_UNSPECIFIED = 2,
    AVIF_MATRIX_COEFFICIENTS_FCC = 4,
    AVIF_MATRIX_COEFFICIENTS_BT470BG = 5,
    AVIF_MATRIX_COEFFICIENTS_BT601 = 6,
    AVIF_MATRIX_COEFFICIENTS_SMPTE240 = 7,
    AVIF_MATRIX_COEFFICIENTS_YCGCO = 8,
    AVIF_MATRIX_COEFFICIENTS_BT2020_NCL = 9,
    AVIF_MATRIX_COEFFICIENTS_BT2020_CL = 10,
    AVIF_MATRIX_COEFFICIENTS_SMPTE2085 = 11,
    AVIF_MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL = 12,
    AVIF_MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL = 13,
    AVIF_MATRIX_COEFFICIENTS_ICTCP = 14,

    AVIF_MATRIX_COEFFICIENTS_LAST = 15
}

alias avifMatrixCoefficients = ushort; // AVIF_MATRIX_COEFFICIENTS_*

// ---------------------------------------------------------------------------
// avifDiagnostics

struct avifDiagnostics
{
    // Upon receiving an error from any non-const libavif API call, if the toplevel structure used
    // in the API call (avifDecoder, avifEncoder) contains a diag member, this buffer may be
    // populated with a NULL-terminated, freeform error string explaining the most recent error in
    // more detail. It will be cleared at the beginning of every non-const API call.
    //
    // Note: If an error string contains the "[Strict]" prefix, it means that you encountered an
    // error that only occurs during strict decoding. If you disable strict mode, you will no
    // longer encounter this error.
    char[AVIF_DIAGNOSTICS_ERROR_BUFFER_SIZE] error;
}

void avifDiagnosticsClearError(avifDiagnostics* diag);

// ---------------------------------------------------------------------------
// Fraction utility

struct avifFraction
{
    int n;
    int d;
}

// ---------------------------------------------------------------------------
// Optional transformation structs

enum avifTransformFlag
{
    AVIF_TRANSFORM_NONE = 0,

    AVIF_TRANSFORM_PASP = (1 << 0),
    AVIF_TRANSFORM_CLAP = (1 << 1),
    AVIF_TRANSFORM_IROT = (1 << 2),
    AVIF_TRANSFORM_IMIR = (1 << 3)
}

alias AVIF_TRANSFORM_NONE = avifTransformFlag.AVIF_TRANSFORM_NONE;
alias AVIF_TRANSFORM_PASP = avifTransformFlag.AVIF_TRANSFORM_PASP;
alias AVIF_TRANSFORM_CLAP = avifTransformFlag.AVIF_TRANSFORM_CLAP;
alias AVIF_TRANSFORM_IROT = avifTransformFlag.AVIF_TRANSFORM_IROT;
alias AVIF_TRANSFORM_IMIR = avifTransformFlag.AVIF_TRANSFORM_IMIR;

alias avifTransformFlags = uint;

struct avifPixelAspectRatioBox
{
    // 'pasp' from ISO/IEC 14496-12:2015 12.1.4.3

    // define the relative width and height of a pixel
    uint hSpacing;
    uint vSpacing;
}

struct avifCleanApertureBox
{
    // 'clap' from ISO/IEC 14496-12:2015 12.1.4.3

    // a fractional number which defines the exact clean aperture width, in counted pixels, of the video image
    uint widthN;
    uint widthD;

    // a fractional number which defines the exact clean aperture height, in counted pixels, of the video image
    uint heightN;
    uint heightD;

    // a fractional number which defines the horizontal offset of clean aperture centre minus (width-1)/2. Typically 0.
    uint horizOffN;
    uint horizOffD;

    // a fractional number which defines the vertical offset of clean aperture centre minus (height-1)/2. Typically 0.
    uint vertOffN;
    uint vertOffD;
}

struct avifImageRotation
{
    // 'irot' from ISO/IEC 23008-12:2017 6.5.10

    // angle * 90 specifies the angle (in anti-clockwise direction) in units of degrees.
    ubyte angle; // legal values: [0-3]
}

struct avifImageMirror
{
    // 'imir' from ISO/IEC 23008-12:2022 6.5.12:
    //
    //     'axis' specifies how the mirroring is performed:
    //
    //     0 indicates that the top and bottom parts of the image are exchanged;
    //     1 specifies that the left and right parts are exchanged.
    //
    //     NOTE In Exif, orientation tag can be used to signal mirroring operations. Exif
    //     orientation tag 4 corresponds to axis = 0 of ImageMirror, and Exif orientation tag 2
    //     corresponds to axis = 1 accordingly.
    //
    // Legal values: [0, 1]
    ubyte axis;
}

// ---------------------------------------------------------------------------
// avifCropRect - Helper struct/functions to work with avifCleanApertureBox

struct avifCropRect
{
    uint x;
    uint y;
    uint width;
    uint height;
}

// These will return AVIF_FALSE if the resultant values violate any standards, and if so, the output
// values are not guaranteed to be complete or correct and should not be used.
avifBool avifCropRectConvertCleanApertureBox(
    avifCropRect* cropRect,
    const(avifCleanApertureBox)* clap,
    uint imageW,
    uint imageH,
    avifPixelFormat yuvFormat,
    avifDiagnostics* diag);
avifBool avifCleanApertureBoxConvertCropRect(
    avifCleanApertureBox* clap,
    const(avifCropRect)* cropRect,
    uint imageW,
    uint imageH,
    avifPixelFormat yuvFormat,
    avifDiagnostics* diag);

// ---------------------------------------------------------------------------
// avifContentLightLevelInformationBox

struct avifContentLightLevelInformationBox
{
    // 'clli' from ISO/IEC 23000-22:2019 (MIAF) 7.4.4.2.2. The SEI message semantics written above
    //  each entry were originally described in ISO/IEC 23008-2.

    // max_content_light_level, when not equal to 0, indicates an upper bound on the maximum light
    // level among all individual samples in a 4:4:4 representation of red, green, and blue colour
    // primary intensities (in the linear light domain) for the pictures of the CLVS, in units of
    // candelas per square metre. When equal to 0, no such upper bound is indicated by
    // max_content_light_level.
    ushort maxCLL;

    // max_pic_average_light_level, when not equal to 0, indicates an upper bound on the maximum
    // average light level among the samples in a 4:4:4 representation of red, green, and blue
    // colour primary intensities (in the linear light domain) for any individual picture of the
    // CLVS, in units of candelas per square metre. When equal to 0, no such upper bound is
    // indicated by max_pic_average_light_level.
    ushort maxPALL;
}

// ---------------------------------------------------------------------------
// avifImage

// NOTE: The avifImage struct may be extended in a future release. Code outside the libavif library
// must allocate avifImage by calling the avifImageCreate() or avifImageCreateEmpty() function.
struct avifImage
{
    // Image information
    uint width;
    uint height;
    uint depth; // all planes must share this depth; if depth>8, all planes are uint16_t internally

    avifPixelFormat yuvFormat;
    avifRange yuvRange;
    avifChromaSamplePosition yuvChromaSamplePosition;
    ubyte*[AVIF_PLANE_COUNT_YUV] yuvPlanes;
    uint[AVIF_PLANE_COUNT_YUV] yuvRowBytes;
    avifBool imageOwnsYUVPlanes;

    ubyte* alphaPlane;
    uint alphaRowBytes;
    avifBool imageOwnsAlphaPlane;
    avifBool alphaPremultiplied;

    // ICC Profile
    avifRWData icc;

    // CICP information:
    // These are stored in the AV1 payload and used to signal YUV conversion. Additionally, if an
    // ICC profile is not specified, these will be stored in the AVIF container's `colr` box with
    // a type of `nclx`. If your system supports ICC profiles, be sure to check for the existence
    // of one (avifImage.icc) before relying on the values listed here!
    avifColorPrimaries colorPrimaries;
    avifTransferCharacteristics transferCharacteristics;
    avifMatrixCoefficients matrixCoefficients;

    // CLLI information:
    // Content Light Level Information. Used to represent maximum and average light level of an
    // image. Useful for tone mapping HDR images, especially when using transfer characteristics
    // SMPTE2084 (PQ). The default value of (0, 0) means the content light level information is
    // unknown or unavailable, and will cause libavif to avoid writing a clli box for it.
    avifContentLightLevelInformationBox clli;

    // Transformations - These metadata values are encoded/decoded when transformFlags are set
    // appropriately, but do not impact/adjust the actual pixel buffers used (images won't be
    // pre-cropped or mirrored upon decode). Basic explanations from the standards are offered in
    // comments above, but for detailed explanations, please refer to the HEIF standard (ISO/IEC
    // 23008-12:2017) and the BMFF standard (ISO/IEC 14496-12:2015).
    //
    // To encode any of these boxes, set the values in the associated box, then enable the flag in
    // transformFlags. On decode, only honor the values in boxes with the associated transform flag set.
    avifTransformFlags transformFlags;
    avifPixelAspectRatioBox pasp;
    avifCleanApertureBox clap;
    avifImageRotation irot;
    avifImageMirror imir;

    // Metadata - set with avifImageSetMetadata*() before write, check .size>0 for existence after read
    avifRWData exif;
    avifRWData xmp;

    // Version 1.0.0 ends here. Add any new members after this line.
}

// avifImageCreate() and avifImageCreateEmpty() return NULL if arguments are invalid or if a memory allocation failed.
avifImage* avifImageCreate(uint width, uint height, uint depth, avifPixelFormat yuvFormat);
avifImage* avifImageCreateEmpty(); // helper for making an image to decode into
avifResult avifImageCopy(avifImage* dstImage, const(avifImage)* srcImage, avifPlanesFlags planes); // deep copy
avifResult avifImageSetViewRect(avifImage* dstImage, const(avifImage)* srcImage, const(avifCropRect)* rect); // shallow copy, no metadata
void avifImageDestroy(avifImage* image);

avifResult avifImageSetProfileICC(avifImage* image, const(ubyte)* icc, size_t iccSize);
// Sets Exif metadata. Attempts to parse the Exif metadata for Exif orientation. Sets
// image->transformFlags, image->irot and image->imir if the Exif metadata is parsed successfully,
// otherwise leaves image->transformFlags, image->irot and image->imir unchanged.
// Warning: If the Exif payload is set and invalid, avifEncoderWrite() may return AVIF_RESULT_INVALID_EXIF_PAYLOAD.
avifResult avifImageSetMetadataExif(avifImage* image, const(ubyte)* exif, size_t exifSize);
// Sets XMP metadata.
avifResult avifImageSetMetadataXMP(avifImage* image, const(ubyte)* xmp, size_t xmpSize);

avifResult avifImageAllocatePlanes(avifImage* image, avifPlanesFlags planes); // Ignores any pre-existing planes
void avifImageFreePlanes(avifImage* image, avifPlanesFlags planes);           // Ignores already-freed planes
void avifImageStealPlanes(avifImage* dstImage, avifImage* srcImage, avifPlanesFlags planes);

// ---------------------------------------------------------------------------
// Understanding maxThreads
//
// libavif's structures and API use the setting 'maxThreads' in a few places. The intent of this
// setting is to limit concurrent thread activity/usage, not necessarily to put a hard ceiling on
// how many sleeping threads happen to exist behind the scenes. The goal of this setting is to
// ensure that at any given point during libavif's encoding or decoding, no more than *maxThreads*
// threads are simultaneously **active and taking CPU time**.
//
// As an important example, when encoding an image sequence that has an alpha channel, two
// long-lived underlying AV1 encoders must simultaneously exist (one for color, one for alpha). For
// each additional frame fed into libavif, its YUV planes are fed into one instance of the AV1
// encoder, and its alpha plane is fed into another. These operations happen serially, so only one
// of these AV1 encoders is ever active at a time. However, the AV1 encoders might pre-create a
// pool of worker threads upon initialization, so during this process, twice the amount of worker
// threads actually simultaneously exist on the machine, but half of them are guaranteed to be
// sleeping.
//
// This design ensures that AV1 implementations are given as many threads as possible to ensure a
// speedy encode or decode, despite the complexities of occasionally needing two AV1 codec instances
// (due to alpha payloads being separate from color payloads). If your system has a hard ceiling on
// the number of threads that can ever be in flight at a given time, please account for this
// accordingly.

// ---------------------------------------------------------------------------
// Optional YUV<->RGB support

// To convert to/from RGB, create an avifRGBImage on the stack, call avifRGBImageSetDefaults() on
// it, and then tweak the values inside of it accordingly. At a minimum, you should populate
// ->pixels and ->rowBytes with an appropriately sized pixel buffer, which should be at least
// (->rowBytes * ->height) bytes, where ->rowBytes is at least (->width * avifRGBImagePixelSize()).
// If you don't want to supply your own pixel buffer, you can use the
// avifRGBImageAllocatePixels()/avifRGBImageFreePixels() convenience functions.

// avifImageRGBToYUV() and avifImageYUVToRGB() will perform depth rescaling and limited<->full range
// conversion, if necessary. Pixels in an avifRGBImage buffer are always full range, and conversion
// routines will fail if the width and height don't match the associated avifImage.

// If libavif is built with a version of libyuv offering a fast conversion between RGB and YUV for
// the given inputs, libavif will use it. See reformat_libyuv.c for the details.
// libyuv is faster but may have slightly less precision than built-in conversion, so avoidLibYUV
// can be set to AVIF_TRUE when AVIF_CHROMA_UPSAMPLING_BEST_QUALITY or
// AVIF_CHROMA_DOWNSAMPLING_BEST_QUALITY is used, to get the most precise but slowest results.

// Note to libavif maintainers: The lookup tables in avifImageYUVToRGBLibYUV
// rely on the ordering of this enum values for their correctness. So changing
// the values in this enum will require auditing avifImageYUVToRGBLibYUV for
// correctness.
enum avifRGBFormat
{
    AVIF_RGB_FORMAT_RGB = 0,
    AVIF_RGB_FORMAT_RGBA = 1, // This is the default format set in avifRGBImageSetDefaults().
    AVIF_RGB_FORMAT_ARGB = 2,
    AVIF_RGB_FORMAT_BGR = 3,
    AVIF_RGB_FORMAT_BGRA = 4,
    AVIF_RGB_FORMAT_ABGR = 5,
    // RGB_565 format uses five bits for the red and blue components and six
    // bits for the green component. Each RGB pixel is 16 bits (2 bytes), which
    // is packed as follows:
    //   uint16_t: [r4 r3 r2 r1 r0 g5 g4 g3 g2 g1 g0 b4 b3 b2 b1 b0]
    //   r4 and r0 are the MSB and LSB of the red component respectively.
    //   g5 and g0 are the MSB and LSB of the green component respectively.
    //   b4 and b0 are the MSB and LSB of the blue component respectively.
    // This format is only supported for YUV -> RGB conversion and when
    // avifRGBImage.depth is set to 8.
    AVIF_RGB_FORMAT_RGB_565 = 6,
    AVIF_RGB_FORMAT_COUNT = 7
}

alias AVIF_RGB_FORMAT_RGB = avifRGBFormat.AVIF_RGB_FORMAT_RGB;
alias AVIF_RGB_FORMAT_RGBA = avifRGBFormat.AVIF_RGB_FORMAT_RGBA;
alias AVIF_RGB_FORMAT_ARGB = avifRGBFormat.AVIF_RGB_FORMAT_ARGB;
alias AVIF_RGB_FORMAT_BGR = avifRGBFormat.AVIF_RGB_FORMAT_BGR;
alias AVIF_RGB_FORMAT_BGRA = avifRGBFormat.AVIF_RGB_FORMAT_BGRA;
alias AVIF_RGB_FORMAT_ABGR = avifRGBFormat.AVIF_RGB_FORMAT_ABGR;
alias AVIF_RGB_FORMAT_RGB_565 = avifRGBFormat.AVIF_RGB_FORMAT_RGB_565;
alias AVIF_RGB_FORMAT_COUNT = avifRGBFormat.AVIF_RGB_FORMAT_COUNT;

uint avifRGBFormatChannelCount(avifRGBFormat format);
avifBool avifRGBFormatHasAlpha(avifRGBFormat format);

enum avifChromaUpsampling
{
    AVIF_CHROMA_UPSAMPLING_AUTOMATIC = 0,    // Chooses best trade off of speed/quality (uses BILINEAR libyuv if available,
                                             // or falls back to NEAREST libyuv if available, or falls back to BILINEAR built-in)
    AVIF_CHROMA_UPSAMPLING_FASTEST = 1,      // Chooses speed over quality (same as NEAREST)
    AVIF_CHROMA_UPSAMPLING_BEST_QUALITY = 2, // Chooses the best quality upsampling, given settings (same as BILINEAR)
    AVIF_CHROMA_UPSAMPLING_NEAREST = 3,      // Uses nearest-neighbor filter
    AVIF_CHROMA_UPSAMPLING_BILINEAR = 4      // Uses bilinear filter
}

alias AVIF_CHROMA_UPSAMPLING_AUTOMATIC = avifChromaUpsampling.AVIF_CHROMA_UPSAMPLING_AUTOMATIC;
alias AVIF_CHROMA_UPSAMPLING_FASTEST = avifChromaUpsampling.AVIF_CHROMA_UPSAMPLING_FASTEST;
alias AVIF_CHROMA_UPSAMPLING_BEST_QUALITY = avifChromaUpsampling.AVIF_CHROMA_UPSAMPLING_BEST_QUALITY;
alias AVIF_CHROMA_UPSAMPLING_NEAREST = avifChromaUpsampling.AVIF_CHROMA_UPSAMPLING_NEAREST;
alias AVIF_CHROMA_UPSAMPLING_BILINEAR = avifChromaUpsampling.AVIF_CHROMA_UPSAMPLING_BILINEAR;

enum avifChromaDownsampling
{
    AVIF_CHROMA_DOWNSAMPLING_AUTOMATIC = 0,    // Chooses best trade off of speed/quality (same as AVERAGE)
    AVIF_CHROMA_DOWNSAMPLING_FASTEST = 1,      // Chooses speed over quality (same as AVERAGE)
    AVIF_CHROMA_DOWNSAMPLING_BEST_QUALITY = 2, // Chooses the best quality upsampling (same as AVERAGE)
    AVIF_CHROMA_DOWNSAMPLING_AVERAGE = 3,      // Uses averaging filter
    AVIF_CHROMA_DOWNSAMPLING_SHARP_YUV = 4     // Uses sharp yuv filter (libsharpyuv), available for 4:2:0 only, ignored for 4:2:2
}

alias AVIF_CHROMA_DOWNSAMPLING_AUTOMATIC = avifChromaDownsampling.AVIF_CHROMA_DOWNSAMPLING_AUTOMATIC;
alias AVIF_CHROMA_DOWNSAMPLING_FASTEST = avifChromaDownsampling.AVIF_CHROMA_DOWNSAMPLING_FASTEST;
alias AVIF_CHROMA_DOWNSAMPLING_BEST_QUALITY = avifChromaDownsampling.AVIF_CHROMA_DOWNSAMPLING_BEST_QUALITY;
alias AVIF_CHROMA_DOWNSAMPLING_AVERAGE = avifChromaDownsampling.AVIF_CHROMA_DOWNSAMPLING_AVERAGE;
alias AVIF_CHROMA_DOWNSAMPLING_SHARP_YUV = avifChromaDownsampling.AVIF_CHROMA_DOWNSAMPLING_SHARP_YUV;

// NOTE: avifRGBImage must be initialized with avifRGBImageSetDefaults() (preferred) or memset()
// before use.
struct avifRGBImage
{
    uint width;           // must match associated avifImage
    uint height;          // must match associated avifImage
    uint depth;           // legal depths [8, 10, 12, 16]. if depth>8, pixels must be uint16_t internally
    avifRGBFormat format; // all channels are always full range
    avifChromaUpsampling chromaUpsampling; // How to upsample from 4:2:0 or 4:2:2 UV when converting to RGB (ignored for 4:4:4 and 4:0:0).
                                           // Ignored when converting to YUV. Defaults to AVIF_CHROMA_UPSAMPLING_AUTOMATIC.
    avifChromaDownsampling chromaDownsampling; // How to downsample to 4:2:0 or 4:2:2 UV when converting from RGB (ignored for 4:4:4 and 4:0:0).
                                               // Ignored when converting to RGB. Defaults to AVIF_CHROMA_DOWNSAMPLING_AUTOMATIC.
    avifBool avoidLibYUV; // If AVIF_FALSE and libyuv conversion between RGB and YUV (including upsampling or downsampling if any)
                          // is available for the avifImage/avifRGBImage combination, then libyuv is used. Default is AVIF_FALSE.
    avifBool ignoreAlpha; // Used for XRGB formats, treats formats containing alpha (such as ARGB) as if they were RGB, treating
                          // the alpha bits as if they were all 1.
    avifBool alphaPremultiplied; // indicates if RGB value is pre-multiplied by alpha. Default: false
    avifBool isFloat; // indicates if RGBA values are in half float (f16) format. Valid only when depth == 16. Default: false
    int maxThreads; // Number of threads to be used for the YUV to RGB conversion. Note that this value is ignored for RGB to YUV
                    // conversion. Setting this to zero has the same effect as setting it to one. Negative values are invalid.
                    // Default: 1.

    ubyte* pixels;
    uint rowBytes;
}

// Sets rgb->width, rgb->height, and rgb->depth to image->width, image->height, and image->depth.
// Sets rgb->pixels to NULL and rgb->rowBytes to 0. Sets the other fields of 'rgb' to default
// values.
void avifRGBImageSetDefaults(avifRGBImage* rgb, const(avifImage)* image);
uint avifRGBImagePixelSize(const(avifRGBImage)* rgb);

// Convenience functions. If you supply your own pixels/rowBytes, you do not need to use these.
avifResult avifRGBImageAllocatePixels(avifRGBImage* rgb);
void avifRGBImageFreePixels(avifRGBImage* rgb);

// The main conversion functions
avifResult avifImageRGBToYUV(avifImage* image, const(avifRGBImage)* rgb);
avifResult avifImageYUVToRGB(const(avifImage)* image, avifRGBImage* rgb);

// Premultiply handling functions.
// (Un)premultiply is automatically done by the main conversion functions above,
// so usually you don't need to call these. They are there for convenience.
avifResult avifRGBImagePremultiplyAlpha(avifRGBImage* rgb);
avifResult avifRGBImageUnpremultiplyAlpha(avifRGBImage* rgb);

// ---------------------------------------------------------------------------
// YUV Utils

int avifFullToLimitedY(uint depth, int v);
int avifFullToLimitedUV(uint depth, int v);
int avifLimitedToFullY(uint depth, int v);
int avifLimitedToFullUV(uint depth, int v);

// ---------------------------------------------------------------------------
// Codec selection

enum avifCodecChoice
{
    AVIF_CODEC_CHOICE_AUTO = 0,
    AVIF_CODEC_CHOICE_AOM = 1,
    AVIF_CODEC_CHOICE_DAV1D = 2,   // Decode only
    AVIF_CODEC_CHOICE_LIBGAV1 = 3, // Decode only
    AVIF_CODEC_CHOICE_RAV1E = 4,   // Encode only
    AVIF_CODEC_CHOICE_SVT = 5,     // Encode only
    AVIF_CODEC_CHOICE_AVM = 6      // Experimental (AV2)
}

alias AVIF_CODEC_CHOICE_AUTO = avifCodecChoice.AVIF_CODEC_CHOICE_AUTO;
alias AVIF_CODEC_CHOICE_AOM = avifCodecChoice.AVIF_CODEC_CHOICE_AOM;
alias AVIF_CODEC_CHOICE_DAV1D = avifCodecChoice.AVIF_CODEC_CHOICE_DAV1D;
alias AVIF_CODEC_CHOICE_LIBGAV1 = avifCodecChoice.AVIF_CODEC_CHOICE_LIBGAV1;
alias AVIF_CODEC_CHOICE_RAV1E = avifCodecChoice.AVIF_CODEC_CHOICE_RAV1E;
alias AVIF_CODEC_CHOICE_SVT = avifCodecChoice.AVIF_CODEC_CHOICE_SVT;
alias AVIF_CODEC_CHOICE_AVM = avifCodecChoice.AVIF_CODEC_CHOICE_AVM;

enum avifCodecFlag
{
    AVIF_CODEC_FLAG_CAN_DECODE = (1 << 0),
    AVIF_CODEC_FLAG_CAN_ENCODE = (1 << 1)
}

alias AVIF_CODEC_FLAG_CAN_DECODE = avifCodecFlag.AVIF_CODEC_FLAG_CAN_DECODE;
alias AVIF_CODEC_FLAG_CAN_ENCODE = avifCodecFlag.AVIF_CODEC_FLAG_CAN_ENCODE;

alias avifCodecFlags = uint;

// If this returns NULL, the codec choice/flag combination is unavailable
const(char)* avifCodecName(avifCodecChoice choice, avifCodecFlags requiredFlags);
avifCodecChoice avifCodecChoiceFromName(const(char)* name);

// ---------------------------------------------------------------------------
// avifIO

// Destroy must completely destroy all child structures *and* free the avifIO object itself.
// This function pointer is optional, however, if the avifIO object isn't intended to be owned by
// a libavif encoder/decoder.
alias avifIODestroyFunc = void function(avifIO* io);

// This function should return a block of memory that *must* remain valid until another read call to
// this avifIO struct is made (reusing a read buffer is acceptable/expected).
//
// * If offset exceeds the size of the content (past EOF), return AVIF_RESULT_IO_ERROR.
// * If offset is *exactly* at EOF, provide a 0-byte buffer and return AVIF_RESULT_OK.
// * If (offset+size) exceeds the contents' size, it must truncate the range to provide all
//   bytes from the offset to EOF.
// * If the range is unavailable yet (due to network conditions or any other reason),
//   return AVIF_RESULT_WAITING_ON_IO.
// * Otherwise, provide the range and return AVIF_RESULT_OK.
alias avifIOReadFunc = avifResult function(avifIO* io, uint readFlags, ulong offset, size_t size, avifROData* out_);

alias avifIOWriteFunc = avifResult function(avifIO* io, uint writeFlags, ulong offset, const(ubyte)* data, size_t size);

struct avifIO
{
    avifIODestroyFunc destroy;
    avifIOReadFunc read;

    // This is reserved for future use - but currently ignored. Set it to a null pointer.
    avifIOWriteFunc write;

    // If non-zero, this is a hint to internal structures of the max size offered by the content
    // this avifIO structure is reading. If it is a static memory source, it should be the size of
    // the memory buffer; if it is a file, it should be the file's size. If this information cannot
    // be known (as it is streamed-in), set a reasonable upper boundary here (larger than the file
    // can possibly be for your environment, but within your environment's memory constraints). This
    // is used for sanity checks when allocating internal buffers to protect against
    // malformed/malicious files.
    ulong sizeHint;

    // If true, *all* memory regions returned from *all* calls to read are guaranteed to be
    // persistent and exist for the lifetime of the avifIO object. If false, libavif will make
    // in-memory copies of samples and metadata content, and a memory region returned from read must
    // only persist until the next call to read.
    avifBool persistent;

    // The contents of this are defined by the avifIO implementation, and should be fully destroyed
    // by the implementation of the associated destroy function, unless it isn't owned by the avifIO
    // struct. It is not necessary to use this pointer in your implementation.
    void* data;
}

avifIO* avifIOCreateMemoryReader(const(ubyte)* data, size_t size);
avifIO* avifIOCreateFileReader(const(char)* filename);
void avifIODestroy(avifIO* io);

// ---------------------------------------------------------------------------
// avifDecoder

// Some encoders (including very old versions of avifenc) do not implement the AVIF standard
// perfectly, and thus create invalid files. However, these files are likely still recoverable /
// decodable, if it wasn't for the strict requirements imposed by libavif's decoder. These flags
// allow a user of avifDecoder to decide what level of strictness they want in their project.
enum avifStrictFlag
{
    // Disables all strict checks.
    AVIF_STRICT_DISABLED = 0,

    // Requires the PixelInformationProperty ('pixi') be present in AV1 image items. libheif v1.11.0
    // or older does not add the 'pixi' item property to AV1 image items. If you need to decode AVIF
    // images encoded by libheif v1.11.0 or older, be sure to disable this bit. (This issue has been
    // corrected in libheif v1.12.0.)
    AVIF_STRICT_PIXI_REQUIRED = (1 << 0),

    // This demands that the values surfaced in the clap box are valid, determined by attempting to
    // convert the clap box to a crop rect using avifCropRectConvertCleanApertureBox(). If this
    // function returns AVIF_FALSE and this strict flag is set, the decode will fail.
    AVIF_STRICT_CLAP_VALID = (1 << 1),

    // Requires the ImageSpatialExtentsProperty ('ispe') be present in alpha auxiliary image items.
    // avif-serialize 0.7.3 or older does not add the 'ispe' item property to alpha auxiliary image
    // items. If you need to decode AVIF images encoded by the cavif encoder with avif-serialize
    // 0.7.3 or older, be sure to disable this bit. (This issue has been corrected in avif-serialize
    // 0.7.4.) See https://github.com/kornelski/avif-serialize/issues/3 and
    // https://crbug.com/1246678.
    AVIF_STRICT_ALPHA_ISPE_REQUIRED = (1 << 2),

    // Maximum strictness; enables all bits above. This is avifDecoder's default.
    AVIF_STRICT_ENABLED = AVIF_STRICT_PIXI_REQUIRED | AVIF_STRICT_CLAP_VALID | AVIF_STRICT_ALPHA_ISPE_REQUIRED
}

alias AVIF_STRICT_DISABLED = avifStrictFlag.AVIF_STRICT_DISABLED;
alias AVIF_STRICT_PIXI_REQUIRED = avifStrictFlag.AVIF_STRICT_PIXI_REQUIRED;
alias AVIF_STRICT_CLAP_VALID = avifStrictFlag.AVIF_STRICT_CLAP_VALID;
alias AVIF_STRICT_ALPHA_ISPE_REQUIRED = avifStrictFlag.AVIF_STRICT_ALPHA_ISPE_REQUIRED;
alias AVIF_STRICT_ENABLED = avifStrictFlag.AVIF_STRICT_ENABLED;

alias avifStrictFlags = uint;

// Useful stats related to a read/write
struct avifIOStats
{
    // Size in bytes of the AV1 image item or track data containing color samples.
    size_t colorOBUSize;
    // Size in bytes of the AV1 image item or track data containing alpha samples.
    size_t alphaOBUSize;
}

struct avifDecoderData;

enum avifDecoderSource
{
    // Honor the major brand signaled in the beginning of the file to pick between an AVIF sequence
    // ('avis', tracks-based) or a single image ('avif', item-based). If the major brand is neither
    // of these, prefer the AVIF sequence ('avis', tracks-based), if present.
    AVIF_DECODER_SOURCE_AUTO = 0,

    // Use the primary item and the aux (alpha) item in the avif(s).
    // This is where single-image avifs store their image.
    AVIF_DECODER_SOURCE_PRIMARY_ITEM = 1,

    // Use the chunks inside primary/aux tracks in the moov block.
    // This is where avifs image sequences store their images.
    AVIF_DECODER_SOURCE_TRACKS = 2

    // Decode the thumbnail item. Currently unimplemented.
    // AVIF_DECODER_SOURCE_THUMBNAIL_ITEM
}

alias AVIF_DECODER_SOURCE_AUTO = avifDecoderSource.AVIF_DECODER_SOURCE_AUTO;
alias AVIF_DECODER_SOURCE_PRIMARY_ITEM = avifDecoderSource.AVIF_DECODER_SOURCE_PRIMARY_ITEM;
alias AVIF_DECODER_SOURCE_TRACKS = avifDecoderSource.AVIF_DECODER_SOURCE_TRACKS;

// Information about the timing of a single image in an image sequence
struct avifImageTiming
{
    ulong timescale;            // timescale of the media (Hz)
    double pts;                 // presentation timestamp in seconds (ptsInTimescales / timescale)
    ulong ptsInTimescales;      // presentation timestamp in "timescales"
    double duration;            // in seconds (durationInTimescales / timescale)
    ulong durationInTimescales; // duration in "timescales"
}

enum avifProgressiveState
{
    // The current AVIF/Source does not offer a progressive image. This will always be the state
    // for an image sequence.
    AVIF_PROGRESSIVE_STATE_UNAVAILABLE = 0,

    // The current AVIF/Source offers a progressive image, but avifDecoder.allowProgressive is not
    // enabled, so it will behave as if the image was not progressive and will simply decode the
    // best version of this item.
    AVIF_PROGRESSIVE_STATE_AVAILABLE = 1,

    // The current AVIF/Source offers a progressive image, and avifDecoder.allowProgressive is true.
    // In this state, avifDecoder.imageCount will be the count of all of the available progressive
    // layers, and any specific layer can be decoded using avifDecoderNthImage() as if it was an
    // image sequence, or simply using repeated calls to avifDecoderNextImage() to decode better and
    // better versions of this image.
    AVIF_PROGRESSIVE_STATE_ACTIVE = 2
}

alias AVIF_PROGRESSIVE_STATE_UNAVAILABLE = avifProgressiveState.AVIF_PROGRESSIVE_STATE_UNAVAILABLE;
alias AVIF_PROGRESSIVE_STATE_AVAILABLE = avifProgressiveState.AVIF_PROGRESSIVE_STATE_AVAILABLE;
alias AVIF_PROGRESSIVE_STATE_ACTIVE = avifProgressiveState.AVIF_PROGRESSIVE_STATE_ACTIVE;

const(char)* avifProgressiveStateToString(avifProgressiveState progressiveState);

// NOTE: The avifDecoder struct may be extended in a future release. Code outside the libavif
// library must allocate avifDecoder by calling the avifDecoderCreate() function.
struct avifDecoder
{
    // --------------------------------------------------------------------------------------------
    // Inputs

    // Defaults to AVIF_CODEC_CHOICE_AUTO: Preference determined by order in availableCodecs table (avif.c)
    avifCodecChoice codecChoice;

    // Defaults to 1. -- NOTE: Please see the "Understanding maxThreads" comment block above
    int maxThreads;

    // avifs can have multiple sets of images in them. This specifies which to decode.
    // Set this via avifDecoderSetSource().
    avifDecoderSource requestedSource;

    // If this is true and a progressive AVIF is decoded, avifDecoder will behave as if the AVIF is
    // an image sequence, in that it will set imageCount to the number of progressive frames
    // available, and avifDecoderNextImage()/avifDecoderNthImage() will allow for specific layers
    // of a progressive image to be decoded. To distinguish between a progressive AVIF and an AVIF
    // image sequence, inspect avifDecoder.progressiveState.
    avifBool allowProgressive;

    // If this is false, avifDecoderNextImage() will start decoding a frame only after there are
    // enough input bytes to decode all of that frame. If this is true, avifDecoder will decode each
    // subimage or grid cell as soon as possible. The benefits are: grid images may be partially
    // displayed before being entirely available, and the overall decoding may finish earlier.
    // Must be set before calling avifDecoderNextImage() or avifDecoderNthImage().
    // WARNING: Experimental feature.
    avifBool allowIncremental;

    // Enable any of these to avoid reading and surfacing specific data to the decoded avifImage.
    // These can be useful if your avifIO implementation heavily uses AVIF_RESULT_WAITING_ON_IO for
    // streaming data, as some of these payloads are (unfortunately) packed at the end of the file,
    // which will cause avifDecoderParse() to return AVIF_RESULT_WAITING_ON_IO until it finds them.
    // If you don't actually leverage this data, it is best to ignore it here.
    avifBool ignoreExif;
    avifBool ignoreXMP;

    // This represents the maximum size of an image (in pixel count) that libavif and the underlying
    // AV1 decoder should attempt to decode. It defaults to AVIF_DEFAULT_IMAGE_SIZE_LIMIT, and can
    // be set to a smaller value. The value 0 is reserved.
    // Note: Only some underlying AV1 codecs support a configurable size limit (such as dav1d).
    uint imageSizeLimit;

    // This represents the maximum dimension of an image (width or height) that libavif should
    // attempt to decode. It defaults to AVIF_DEFAULT_IMAGE_DIMENSION_LIMIT. Set it to 0 to ignore
    // the limit.
    uint imageDimensionLimit;

    // This provides an upper bound on how many images the decoder is willing to attempt to decode,
    // to provide a bit of protection from malicious or malformed AVIFs citing millions upon
    // millions of frames, only to be invalid later. The default is AVIF_DEFAULT_IMAGE_COUNT_LIMIT
    // (see comment above), and setting this to 0 disables the limit.
    uint imageCountLimit;

    // Strict flags. Defaults to AVIF_STRICT_ENABLED. See avifStrictFlag definitions above.
    avifStrictFlags strictFlags;

    // --------------------------------------------------------------------------------------------
    // Outputs

    // All decoded image data; owned by the decoder. All information in this image is incrementally
    // added and updated as avifDecoder*() functions are called. After a successful call to
    // avifDecoderParse(), all values in decoder->image (other than the planes/rowBytes themselves)
    // will be pre-populated with all information found in the outer AVIF container, prior to any
    // AV1 decoding. If the contents of the inner AV1 payload disagree with the outer container,
    // these values may change after calls to avifDecoderRead*(),avifDecoderNextImage(), or
    // avifDecoderNthImage().
    //
    // The YUV and A contents of this image are likely owned by the decoder, so be sure to copy any
    // data inside of this image before advancing to the next image or reusing the decoder. It is
    // legal to call avifImageYUVToRGB() on this in between calls to avifDecoderNextImage(), but use
    // avifImageCopy() if you want to make a complete, permanent copy of this image's YUV content or
    // metadata.
    avifImage* image;

    // Counts and timing for the current image in an image sequence. Uninteresting for single image files.
    int imageIndex;                // 0-based
    int imageCount;                // Always 1 for non-progressive, non-sequence AVIFs.
    avifProgressiveState progressiveState; // See avifProgressiveState declaration
    avifImageTiming imageTiming;   //
    ulong timescale;               // timescale of the media (Hz)
    double duration;               // duration of a single playback of the image sequence in seconds
                                   // (durationInTimescales / timescale)
    ulong durationInTimescales;    // duration of a single playback of the image sequence in "timescales"
    int repetitionCount;           // number of times the sequence has to be repeated. This can also be one of
                                   // AVIF_REPETITION_COUNT_INFINITE or AVIF_REPETITION_COUNT_UNKNOWN. Essentially, if
                                   // repetitionCount is a non-negative integer `n`, then the image sequence should be
                                   // played back `n + 1` times.

    // This is true when avifDecoderParse() detects an alpha plane. Use this to find out if alpha is
    // present after a successful call to avifDecoderParse(), but prior to any call to
    // avifDecoderNextImage() or avifDecoderNthImage(), as decoder->image->alphaPlane won't exist yet.
    avifBool alphaPresent;

    // stats from the most recent read, possibly 0s if reading an image sequence
    avifIOStats ioStats;

    // Additional diagnostics (such as detailed error state)
    avifDiagnostics diag;

    // --------------------------------------------------------------------------------------------
    // Internals

    // Use one of the avifDecoderSetIO*() functions to set this
    avifIO* io;

    // Internals used by the decoder
    avifDecoderData* data;

    // Version 1.0.0 ends here. Add any new members after this line.
}

avifDecoder* avifDecoderCreate();
void avifDecoderDestroy(avifDecoder* decoder);

// Simple interfaces to decode a single image, independent of the decoder afterwards (decoder may be destroyed).
avifResult avifDecoderRead(avifDecoder* decoder, avifImage* image); // call avifDecoderSetIO*() first
avifResult avifDecoderReadMemory(avifDecoder* decoder, avifImage* image, const(ubyte)* data, size_t size);
avifResult avifDecoderReadFile(avifDecoder* decoder, avifImage* image, const(char)* filename);

// Multi-function alternative to avifDecoderRead() for image sequences and gaining direct access
// to the decoder's YUV buffers (for performance's sake). Data passed into avifDecoderParse() is NOT
// copied, so it must continue to exist until the decoder is destroyed.
//
// Usage / function call order is:
// * avifDecoderCreate()
// * avifDecoderSetSource() - optional, the default (AVIF_DECODER_SOURCE_AUTO) is usually sufficient
// * avifDecoderSetIO*()
// * avifDecoderParse()
// * avifDecoderNextImage() - in a loop, using decoder->image after each successful call
// * avifDecoderDestroy()
//
// NOTE: Until avifDecoderParse() returns AVIF_RESULT_OK, no data in avifDecoder should
//       be considered valid, and no queries (such as Keyframe/Timing/MaxExtent) should be made.
//
// You can use avifDecoderReset() any time after a successful call to avifDecoderParse()
// to reset the internal decoder back to before the first frame. Calling either
// avifDecoderSetSource() or avifDecoderParse() will automatically Reset the decoder.
//
// avifDecoderSetSource() allows you not only to choose whether to parse tracks or
// items in a file containing both, but switch between sources without having to
// Parse again. Normally AVIF_DECODER_SOURCE_AUTO is enough for the common path.
avifResult avifDecoderSetSource(avifDecoder* decoder, avifDecoderSource source);
// Note: When avifDecoderSetIO() is called, whether 'decoder' takes ownership of 'io' depends on
// whether io->destroy is set. avifDecoderDestroy(decoder) calls avifIODestroy(io), which calls
// io->destroy(io) if io->destroy is set. Therefore, if io->destroy is not set, then
// avifDecoderDestroy(decoder) has no effects on 'io'.
void avifDecoderSetIO(avifDecoder* decoder, avifIO* io);
avifResult avifDecoderSetIOMemory(avifDecoder* decoder, const(ubyte)* data, size_t size);
avifResult avifDecoderSetIOFile(avifDecoder* decoder, const(char)* filename);
avifResult avifDecoderParse(avifDecoder* decoder);
avifResult avifDecoderNextImage(avifDecoder* decoder);
avifResult avifDecoderNthImage(avifDecoder* decoder, uint frameIndex);
avifResult avifDecoderReset(avifDecoder* decoder);

// Keyframe information
// frameIndex - 0-based, matching avifDecoder->imageIndex, bound by avifDecoder->imageCount
// "nearest" keyframe means the keyframe prior to this frame index (returns frameIndex if it is a keyframe)
// These functions may be used after a successful call (AVIF_RESULT_OK) to avifDecoderParse().
avifBool avifDecoderIsKeyframe(const(avifDecoder)* decoder, uint frameIndex);
uint avifDecoderNearestKeyframe(const(avifDecoder)* decoder, uint frameIndex);

// Timing helper - This does not change the current image or invoke the codec (safe to call repeatedly)
// This function may be used after a successful call (AVIF_RESULT_OK) to avifDecoderParse().
avifResult avifDecoderNthImageTiming(const(avifDecoder)* decoder, uint frameIndex, avifImageTiming* outTiming);

// When avifDecoderNextImage() or avifDecoderNthImage() returns AVIF_RESULT_WAITING_ON_IO, this
// function can be called next to retrieve the number of top rows that can be immediately accessed
// from the luma plane of decoder->image, and alpha if any. The corresponding rows from the chroma planes,
// if any, can also be accessed (half rounded up if subsampled, same number of rows otherwise).
// decoder->allowIncremental must be set to true before calling avifDecoderNextImage() or
// avifDecoderNthImage(). Returns decoder->image->height when the last call to avifDecoderNextImage() or
// avifDecoderNthImage() returned AVIF_RESULT_OK. Returns 0 in all other cases.
// WARNING: Experimental feature.
uint avifDecoderDecodedRowCount(const(avifDecoder)* decoder);

// ---------------------------------------------------------------------------
// avifExtent

struct avifExtent
{
    ulong offset;
    size_t size;
}

// Streaming data helper - Use this to calculate the maximal AVIF data extent encompassing all AV1
// sample data needed to decode the Nth image. The offset will be the earliest offset of all
// required AV1 extents for this frame, and the size will create a range including the last byte of
// the last AV1 sample needed. Note that this extent may include non-sample data, as a frame's
// sample data may be broken into multiple extents and interleaved with other data, or in
// non-sequential order. This extent will also encompass all AV1 samples that this frame's sample
// depends on to decode (such as samples for reference frames), from the nearest keyframe up to this
// Nth frame.
//
// If avifDecoderNthImageMaxExtent() returns AVIF_RESULT_OK and the extent's size is 0 bytes, this
// signals that libavif doesn't expect to call avifIO's Read for this frame's decode. This happens if
// data for this frame was read as a part of avifDecoderParse() (typically in an idat box inside of
// a meta box).
//
// This function may be used after a successful call (AVIF_RESULT_OK) to avifDecoderParse().
avifResult avifDecoderNthImageMaxExtent(const(avifDecoder)* decoder, uint frameIndex, avifExtent* outExtent);

// ---------------------------------------------------------------------------
// avifEncoder

struct avifEncoderData;
struct avifCodecSpecificOptions;

struct avifScalingMode
{
    avifFraction horizontal;
    avifFraction vertical;
}

// Notes:
// * The avifEncoder struct may be extended in a future release. Code outside the libavif library
//   must allocate avifEncoder by calling the avifEncoderCreate() function.
// * If avifEncoderWrite() returns AVIF_RESULT_OK, output must be freed with avifRWDataFree()
// * If (maxThreads < 2), multithreading is disabled
//   * NOTE: Please see the "Understanding maxThreads" comment block above
// * Quality range: [AVIF_QUALITY_WORST - AVIF_QUALITY_BEST]
// * Quantizer range: [AVIF_QUANTIZER_BEST_QUALITY - AVIF_QUANTIZER_WORST_QUALITY]
// * In older versions of libavif, the avifEncoder struct doesn't have the quality and qualityAlpha
//   fields. For backward compatibility, if the quality field is not set, the default value of
//   quality is based on the average of minQuantizer and maxQuantizer. Similarly the default value
//   of qualityAlpha is based on the average of minQuantizerAlpha and maxQuantizerAlpha. New code
//   should set quality and qualityAlpha and leave minQuantizer, maxQuantizer, minQuantizerAlpha,
//   and maxQuantizerAlpha initialized to their default values.
// * To enable tiling, set tileRowsLog2 > 0 and/or tileColsLog2 > 0.
//   Tiling values range [0-6], where the value indicates a request for 2^n tiles in that dimension.
//   If autoTiling is set to AVIF_TRUE, libavif ignores tileRowsLog2 and tileColsLog2 and
//   automatically chooses suitable tiling values.
// * Speed range: [AVIF_SPEED_SLOWEST - AVIF_SPEED_FASTEST]. Slower should make for a better quality
//   image in less bytes. AVIF_SPEED_DEFAULT means "Leave the AV1 codec to its default speed settings"./
//   If avifEncoder uses rav1e, the speed value is directly passed through (0-10). If libaom is used,
//   a combination of settings are tweaked to simulate this speed range.
// * Extra layer count: [0 - (AVIF_MAX_AV1_LAYER_COUNT-1)]. Non-zero value indicates a layered
//   (progressive) image.
// * Some encoder settings can be changed after encoding starts. Changes will take effect in the next
//   call to avifEncoderAddImage().
struct avifEncoder
{
    // Defaults to AVIF_CODEC_CHOICE_AUTO: Preference determined by order in availableCodecs table (avif.c)
    avifCodecChoice codecChoice;

    // settings (see Notes above)
    int maxThreads;
    int speed;
    int keyframeInterval; // Any set of |keyframeInterval| consecutive frames will have at least one keyframe. When it is 0,
                          // there is no such restriction.
    ulong timescale;      // timescale of the media (Hz)
    int repetitionCount;  // Number of times the image sequence should be repeated. This can also be set to
                          // AVIF_REPETITION_COUNT_INFINITE for infinite repetitions.  Only applicable for image sequences.
                          // Essentially, if repetitionCount is a non-negative integer `n`, then the image sequence should be
                          // played back `n + 1` times. Defaults to AVIF_REPETITION_COUNT_INFINITE.
    uint extraLayerCount; // EXPERIMENTAL: Non-zero value encodes layered image.

    // changeable encoder settings
    int quality;
    int qualityAlpha;
    int minQuantizer;
    int maxQuantizer;
    int minQuantizerAlpha;
    int maxQuantizerAlpha;
    int tileRowsLog2;
    int tileColsLog2;
    avifBool autoTiling;
    avifScalingMode scalingMode;

    // stats from the most recent write
    avifIOStats ioStats;

    // Additional diagnostics (such as detailed error state)
    avifDiagnostics diag;

    // Internals used by the encoder
    avifEncoderData* data;
    avifCodecSpecificOptions* csOptions;

    // Version 1.0.0 ends here. Add any new members after this line.
}

// avifEncoderCreate() returns NULL if a memory allocation failed.
avifEncoder* avifEncoderCreate();
avifResult avifEncoderWrite(avifEncoder* encoder, const(avifImage)* image, avifRWData* output);
void avifEncoderDestroy(avifEncoder* encoder);

enum avifAddImageFlag
{
    AVIF_ADD_IMAGE_FLAG_NONE = 0,

    // Force this frame to be a keyframe (sync frame).
    AVIF_ADD_IMAGE_FLAG_FORCE_KEYFRAME = (1 << 0),

    // Use this flag when encoding a single frame, single layer image.
    // Signals "still_picture" to AV1 encoders, which tweaks various compression rules.
    // This is enabled automatically when using the avifEncoderWrite() single-image encode path.
    AVIF_ADD_IMAGE_FLAG_SINGLE = (1 << 1)
}

alias AVIF_ADD_IMAGE_FLAG_NONE = avifAddImageFlag.AVIF_ADD_IMAGE_FLAG_NONE;
alias AVIF_ADD_IMAGE_FLAG_FORCE_KEYFRAME = avifAddImageFlag.AVIF_ADD_IMAGE_FLAG_FORCE_KEYFRAME;
alias AVIF_ADD_IMAGE_FLAG_SINGLE = avifAddImageFlag.AVIF_ADD_IMAGE_FLAG_SINGLE;

alias avifAddImageFlags = uint;

// Multi-function alternative to avifEncoderWrite() for advanced features.
//
// Usage / function call order is:
// * avifEncoderCreate()
// - Still image:
//   * avifEncoderAddImage() [exactly once]
// - Still image grid:
//   * avifEncoderAddImageGrid() [exactly once, AVIF_ADD_IMAGE_FLAG_SINGLE is assumed]
// - Image sequence:
//   * Set encoder->timescale (Hz) correctly
//   * avifEncoderAddImage() ... [repeatedly; at least once]
// - Still layered image:
//   * Set encoder->extraLayerCount correctly
//   * avifEncoderAddImage() ... [exactly encoder->extraLayerCount+1 times]
// - Still layered grid:
//   * Set encoder->extraLayerCount correctly
//   * avifEncoderAddImageGrid() ... [exactly encoder->extraLayerCount+1 times]
// * avifEncoderFinish()
// * avifEncoderDestroy()
//
// The image passed to avifEncoderAddImage() or avifEncoderAddImageGrid() is encoded during the
// call (which may be slow) and can be freed after the function returns.

// durationInTimescales is ignored if AVIF_ADD_IMAGE_FLAG_SINGLE is set in addImageFlags,
// or if we are encoding a layered image.
avifResult avifEncoderAddImage(avifEncoder* encoder, const(avifImage)* image, ulong durationInTimescales, avifAddImageFlags addImageFlags);
avifResult avifEncoderAddImageGrid(
    avifEncoder* encoder,
    uint gridCols,
    uint gridRows,
    const(avifImage*)* cellImages,
    avifAddImageFlags addImageFlags);
avifResult avifEncoderFinish(avifEncoder* encoder, avifRWData* output);

// Codec-specific, optional "advanced" tuning settings, in the form of string key/value pairs,
// to be consumed by the codec in the next avifEncoderAddImage() call.
// See the codec documentation to know if a setting is persistent or applied only to the next frame.
// key must be non-NULL, but passing a NULL value will delete the pending key, if it exists.
// Setting an incorrect or unknown option for the current codec will cause errors of type
// AVIF_RESULT_INVALID_CODEC_SPECIFIC_OPTION from avifEncoderWrite() or avifEncoderAddImage().
avifResult avifEncoderSetCodecSpecificOption(avifEncoder* encoder, const(char)* key, const(char)* value);

// Helpers
avifBool avifImageUsesU16(const(avifImage)* image);
avifBool avifImageIsOpaque(const(avifImage)* image);
// channel can be an avifChannelIndex.
ubyte* avifImagePlane(const(avifImage)* image, int channel);
uint avifImagePlaneRowBytes (const(avifImage)* image, int channel);
uint avifImagePlaneWidth(const(avifImage)* image, int channel);
uint avifImagePlaneHeight(const(avifImage)* image, int channel);

// Returns AVIF_TRUE if input begins with a valid FileTypeBox (ftyp) that supports
// either the brand 'avif' or 'avis' (or both), without performing any allocations.
avifBool avifPeekCompatibleFileType(const(avifROData)* input);

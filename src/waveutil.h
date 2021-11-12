/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#ifndef WAVEUTIL_H
#define WAVEUTIL_H

#include <stdint.h>
#include <stdio.h> //FILE

class waveutil
{
public:
    waveutil();
};

typedef struct waveFormatHeader {
    char ChunkId[4];
    uint32_t ChunkSize;
    char Format[4];
    char Subchunk1ID[4];
    uint32_t Subchunk1Size;
    uint16_t AudioFormat;
    uint16_t NumChannels;
    uint32_t SampleRate;
    uint32_t ByteRate;
    uint16_t BlockAlign;
    uint16_t BitsPerSample;
    char SubChunk2ID[4];
    uint32_t Subchunk2Size;
} waveFormatHeader_t;

//Usually, just use these two functions to create your header and write it out.
//malloc's and initializes a new header struct
waveFormatHeader_t * stereo16bit44khzWaveHeaderForLength(size_t numberOfFrames);
//writes the header to the given file. currently just an fwrite but could be a member-by-member write in the future.
size_t writeWaveHeaderToFile(waveFormatHeader_t * wh, FILE * file);

//if you want to create the header but set its length at a later date, you can use this. modifies the contents of wh
void setLengthForWaveFormatHeader(waveFormatHeader_t * wh, size_t numberOfFrames);

//Use these functions if you have read the wave header documentation and want to customize the values
waveFormatHeader_t * stereo16bit44khzWaveHeader(void);
waveFormatHeader_t * basicHeader(void);


#endif // WAVEUTIL_H

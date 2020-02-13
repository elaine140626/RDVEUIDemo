#pragma once
#include <stdint.h>
#include <stdio.h> 
//#include <malloc.h>

#include <memory.h>

#pragma pack (2) /*ָ����2�ֽڶ���*/
struct WAVEHEADER
{
    uint32_t   uRiff;			// "RIFF"
	uint32_t   uSize;			// Size
	uint32_t   uWave;			// "WAVE"
};

struct DATA_BLOCK
{
	uint32_t	uDataID;		// 'd','a','t','a'
	uint32_t	uDataSize;
};
struct SWaveFormat
{
	uint16_t	wFormatTag;         /* format type */
	uint16_t	nChannels;          /* number of channels (i.e. mono, stereo...) */
	uint32_t	nSamplesPerSec;     /* sample rate */
	uint32_t	nAvgBytesPerSec;    /* for buffer estimation */
	uint16_t	nBlockAlign;        /* block size of data */
	uint16_t	wBitsPerSample;     /* number of bits per sample of mono data */
	uint16_t	cbSize;             /* the count in bytes of the size of */
									/* extra information (after cbSize) */
};
#pragma pack () /*ȡ��ָ�����룬�ָ�ȱʡ����*/

class CWaveFile
{
public:
	CWaveFile() {}
	~CWaveFile() { closeFile(); }

	//���ļ������ڶ�
	bool openFile( const char* szFileName );
	//���ļ�������д��
	//pWfxInfo �ṹָ�� PCM ���ݵĸ�ʽ���������Ϊ NULL�����ʾ׷�ӣ���ʽ��Ϣ���ļ��ж��롣
	bool openFile( const char* szFileName, const SWaveFormat* pWfxInfo );
	void closeFile();

	uint32_t readSamples( uint32_t uCount, void* pData );
	bool appendSamples( uint32_t uCount, const void* pData );

	const SWaveFormat* getWaveFormat() { return m_pWfxInfo; }
	bool seekToSecond( double dSecond );

	uint32_t byteCountAsSamples() { return m_pWfxInfo ? m_pWfxInfo->nBlockAlign : 0; }
	uint32_t samplesPerSecond() { return m_pWfxInfo ? m_pWfxInfo->nSamplesPerSec : 0; }
	uint32_t sampleCount() { return m_pWfxInfo ? m_uWaveSize / m_pWfxInfo->nBlockAlign : 0; }
	uint16_t channelCount() { return m_pWfxInfo ? m_pWfxInfo->nChannels : 0; }
private:
	FILE*			m_hFile			= nullptr;
	SWaveFormat*	m_pWfxInfo		= nullptr;
	uint32_t		m_uWaveOffset	= 0;
	uint32_t		m_uWaveSize		= 0;
	uint32_t		m_uReadOffset	= 0;
	bool			m_bIsWrite		= false;
	static int MakeFourCC( uint8_t ch0, uint8_t ch1, uint8_t ch2, uint8_t ch3 )
	{
		return ( (uint32_t)ch0 | ( (uint32_t)ch1 << 8 ) | ( (uint32_t)ch2 << 16 ) | ( (uint32_t)ch3 << 24 ) );
	}
	bool updateHead();
};

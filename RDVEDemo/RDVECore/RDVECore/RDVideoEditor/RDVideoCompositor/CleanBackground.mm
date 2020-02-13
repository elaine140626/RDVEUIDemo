#include "CleanBackground.h"
//#include <corecrt_math_defines.h>
#include <math.h>
#include <iostream>
using namespace std;
//#include <QDebug>

#define	DEFUALT_CALC_SIZE		256
CleanBackground::CleanBackground()
{
	m_image	= nullptr;
	m_width = 0;
	m_height = 0;
	m_pitch = 0;

	m_hsv = nullptr;
	m_baseWidth = 0;
	m_baseHeight = 0;
	m_allocSize = 0;
}


CleanBackground::~CleanBackground()
{
	if (m_hsv)
		free(m_hsv);
}

CleanBackground::BackgroundInfo CleanBackground::selectSolid(const uint8_t * sour, int32_t width, int32_t height, int32_t pitch)
{
	m_image = sour;
	m_width = width;
	m_height = height;
	m_pitch = pitch > 0 ? pitch : width * 4;
	memset(&m_bkInfo, 0, sizeof(m_bkInfo));
	//���������ڲ�����ʱʹ�õ�ͼ���ߡ�С�ڻ����Դͼ�񣬽��;��ȣ����ټ���ʱ�䡣
	m_baseWidth = min( m_width, DEFUALT_CALC_SIZE);
	m_baseHeight = min( m_height, DEFUALT_CALC_SIZE);
	int32_t bytes = m_width * 4 * m_height;	//�ڲ�ͼ����ֽ���
	//�����ڲ�ͼ��ʹ�õ��ڴ�
	if (bytes > m_allocSize)
	{
		if (m_hsv) free(m_hsv);
		m_hsv = (uint8_t*)malloc(bytes);
		m_allocSize = bytes;
	}
	//�������ű���
	double	scaleX = double(m_width - 1) / double(m_baseWidth - 1);
	double	scaleY = double(m_height - 1) / double(m_baseHeight - 1);
	int32_t	edgeX = m_baseWidth / 24;
	int32_t	edgeY = m_baseHeight / 24;
	int32_t	offsetX[DEFUALT_CALC_SIZE], offsetY[DEFUALT_CALC_SIZE];		//ͼ������ʱ��Ŀ�����ض�Ӧ��Դͼ�����ص��ֽ�ƫ����
	uint8_t	deltaX[DEFUALT_CALC_SIZE], deltaY[DEFUALT_CALC_SIZE];	//����ֱ��ͼʱ����Ե���ص�Ȩ�ظ��ߣ��Ա���õ���ȡ������ɫ��
	for (int32_t x = 0; x < m_baseWidth; ++x)
	{
		offsetX[x] = (int32_t)floor(scaleX * x + 0.5) * 4;
		int32_t edge = max(edgeX - abs(edgeX - x), edgeX - abs(edgeX - (m_baseWidth - x - 1)));
		deltaX[x] = edge > 0 ? edge * 32 / edgeX : 1;
	}
	for (int32_t y = 0; y < m_baseHeight; ++y)
	{
		offsetY[y] = ((int32_t)floor(scaleY * y + 0.5)) * m_pitch;
		int32_t edge = max(edgeY - abs(edgeY - y), edgeY - abs(edgeY - (m_baseWidth - y - 1)));
		deltaY[y] = edge > 0 ? edge * 32 / edgeY : 1;
	}

	//��Դ RGBA ת��Ϊ HSV��ͬʱ����ֱ��ͼͳ�ơ�
	uint32_t hisV[256] = { 0 };
	uint32_t hisS[256] = { 0 };
	uint32_t hisH[256] = { 0 };
	uint8_t*	d = m_hsv;
	for (int32_t y = 0; y < m_baseHeight; ++y)
	{
		const uint8_t* sline = sour + offsetY[y];
		for (int32_t x = 0; x < m_baseWidth; ++x)
		{
			const uint8_t* s = sline + offsetX[x];
			uint8_t ma = max(s[0], max(s[1], s[2]));
			uint8_t mi = min(s[0], min(s[1], s[2]));
			uint8_t	md = ma - mi;
			d[0] = (ma + mi) >> 1;	//���ȣ���ʹ��RGB���ֵ����ʹ�� (���+��С)/2 �õ���ƽ��ֵ������Ϊ��ʹ�Ұ�ɫ�Ͳ�ɫ�и����Ե�����ֵ���졣
			if (md >=4 &&  ma >= 8)	//�������Ⱥͱ��Ͷȼ�С�����أ����������ǵ�ɫ�࣬��Ϊ������ѹ����Ӱ�쵼����ɫ�б仯���Ӷ���׼ȷ��
			{
				d[1] = md * 255 / ma;	//���Ͷȣ�ʹ��ɫ���ʼ���㱳����Χʱʹ�ã�Ȼ���Դ�Ϊ������ʹ�����ȼ������㱳����Χ��
				if (ma == s[2])
					d[2] = ((((s[1] - s[0]) << 8)) / (6 * md) + 256) % 256;
				else if (ma == s[1])
					d[2] = ((s[0] - s[2] + 2 * md) << 8) / (6 * md);
				else
					d[2] = ((s[2] - s[1] + 4 * md) << 8) / (6 * md);
			}
			else
			{
				d[1] = 0;
				d[2] = 0;
			}
			hisS[d[1]] += deltaX[x] + deltaY[y];	//ͳ��ɫ���ֱ��ͼ��
			hisH[d[2]] += deltaX[x] + deltaY[y];	//ͳ��ɫ����Ͷȣ���ֱ��ͼ��
			d[3] = md;	//��һ�ֱ��Ͷ�ֵ����ʹ��ɫ�෶ΧΪ�������ٴμ��㱳����Χʱ��ʹ�����ֵ��
			d += 4;
		}
	}
	//�ֱ���ɫ���ɫ�������ܵı���ɫ���䡣

	int32_t	backMode = 0;
	BkRange	S = beginRanged(256, hisS);		//����ɫ����������������Χ����Ӧ�Ұױ�����
	BkRange	VS;
	BkRange	V2;
	//uint32_t	VS_R = 0, VS_G = 0, VS_B = 0;
//	qDebug() << "S(" << S.begin << "," << S.end << ")";
	//��ɫ�Χ������ı���Ϊ������ͳ����Щ���ص�����ֱ��ͼ��
	if ( S.end >= 0)
	{
		d = m_hsv;
		for (int32_t y = 0; y < m_baseHeight; ++y)
		{
			for (int32_t x = 0; x < m_baseWidth; ++x)
			{
				if (d[1] <= S.end)
				{
					hisV[d[0]] += deltaX[x] + deltaY[y];
				}
				d += 4;
			}
		}
		VS = lineRanged(256, hisV, false);
		if (VS.end >= VS.begin)
		{
			backMode |= 1;
			memset(hisV, 0, sizeof(hisV));
			memset(hisS, 0, sizeof(hisS));
			d = m_hsv;
			for (int y = 0; y < m_baseHeight; ++y)
			{
				const uint8_t* sline = sour + offsetY[y];
				for (int x = 0; x < m_baseWidth; ++x)
				{
					if (d[1] <= S.end)
					{
						if (VS.begin <= d[0] && d[0] <= VS.end)
						{
							const uint8_t* s = sline + offsetX[x];
							hisS[d[2] / 16 * 16 + d[1] / 16]++;	//ͳ�Ƽ�����ı�����Χ�����غ���ɫ������
						}
						else
						{
							++hisV[d[0]];
						}
					}
					d += 4;
				}
			}
			V2	= lineRanged(256, hisV, false);
		}
	}
	BkRange	H = circleRanged(256, hisH);	//����ɫ����������������Χ����Ӧ��ɫ������
	BkRange	SH;
	//uint32_t	SH_R = 0, SH_G = 0, SH_B = 0;
//	qDebug() << "H(" << H.begin << "," << H.end << ")";
	if (H.end >= 0)
	{
		//��ɫ�෶Χ������ı���Ϊ������ͳ����Щ���ص�ɫ��ֱ��ͼ��
		memset(hisH, 0, sizeof(hisH));
		d = m_hsv;
		for (int y = 0; y < m_baseHeight; ++y)
		{
			for (int x = 0; x < m_baseWidth; ++x)
			{
				if (H.begin <= H.end ? (d[2] >= H.begin && d[2] <= H.end) : (d[2] >= H.begin || d[2] <= H.end))
				{
					hisH[d[3]] += deltaX[x] + deltaY[y];
				}
				d += 4;
			}
		}
		SH = lineRanged(256, hisH, true);
		if (SH.end > SH.begin)
		{
			backMode |= 2;
			memset(hisH, 0, sizeof(hisH));
			memset(hisV, 0, sizeof(hisV));
			d = m_hsv;
			for (int y = 0; y < m_baseHeight; ++y)
			{
				const uint8_t* sline = sour + offsetY[y];
				for (int x = 0; x < m_baseWidth; ++x)
				{
					if (H.begin <= H.end ? (d[2] >= H.begin && d[2] <= H.end) : (d[2] >= H.begin || d[2] <= H.end))
					{
						if (SH.begin <= d[3] && d[3] <= SH.end)
						{
							const uint8_t* s = sline + offsetX[x];
							hisH[d[2] / 16 * 16 + d[1] / 16]++;
						}
						else
						{
							++hisV[d[3]];
						}
					}
					d += 4;
				}
			}
		}
	}

	//�������ַ�ʽ������ı�������ͳ�ƽ�����ж��ǻҰױ������ǲ�ɫ������
	int32_t pixAsSta = 0, colAsSta = 0;
	int32_t pixAsHue = 0, colAsHue = 0;
	for (int i = 0; i < 256; ++i)
	{
		if (hisS[i])
		{
			pixAsSta += hisS[i];
			++colAsSta;
		}
		if (hisH[i])
		{
			pixAsHue += hisH[i];
			++colAsHue;
		}
	}
	switch (backMode)
	{
	case 0:
		return m_bkInfo;
	case 1:
		m_bkInfo.bgMode = 0;
		break;
	case 2:
		m_bkInfo.bgMode = 1;
		break;
	case 3:
	{
		m_bkInfo.bgMode = (pixAsHue / colAsHue > pixAsSta * 3 / colAsSta) ? 1 : 0;
	}
		break;
	}
	if (m_bkInfo.bgMode == 0)
	{
		m_bkInfo.thresholdA = S;
		m_bkInfo.thresholdB = VS;
		m_bkInfo.thresholdC = V2;
	}
	else
	{
		m_bkInfo.thresholdA = H;
		m_bkInfo.thresholdB = SH;
		m_bkInfo.thresholdC = lineRanged(256, hisV, false);
	}
	//d = m_hsv;
	//if (backMode == 3)
	//{rr
	//	for (int y = 0; y < m_baseHeight; ++y)
	//	{
	//		for (int x = 0; x < m_baseWidth; ++x)
	//		{
	//			d[0] = 0;
	//			d += 4;
	//		}
	//	}
	//}
	//else
	//{
	//	for (int y = 0; y < m_baseHeight; ++y)
	//	{
	//		for (int x = 0; x < m_baseWidth; ++x)
	//		{
	//			d[3] = d[0];
	//			d[0] = 0;
	//			d += 4;
	//		}
	//	}
	//}
	return m_bkInfo;
}

CleanBackground::BackgroundInfo CleanBackground::selectSky(const uint8_t* sour, int32_t width, int32_t height, int32_t pitch )
{
	//m_image = sour;
	//m_width = width;
	//m_height = height;
	//m_pitch = pitch > 0 ? pitch : width * 4;
	//memset(&m_bkInfo, 0, sizeof(m_bkInfo));
	////���������ڲ�����ʱʹ�õ�ͼ���ߡ�С�ڻ����Դͼ�񣬽��;��ȣ����ټ���ʱ�䡣
	//m_baseWidth = m_width; //min(m_width, DEFUALT_CALC_SIZE);
	//m_baseHeight = m_height;// min(m_height, DEFUALT_CALC_SIZE);
	//int32_t bytes = m_baseWidth * m_baseHeight;	//�ڲ�ͼ����ֽ���
	////�����ڲ�ͼ��ʹ�õ��ڴ�
	//if (bytes > m_allocSize)
	//{
	//	if (m_hsv) free(m_hsv);
	//	m_hsv = (uint8_t*)malloc(bytes);
	//	m_allocSize = bytes;
	//}
	//uint8_t* d = m_hsv;
	//for (int y = 1; y < height; ++y)
	//{
	//	const uint8_t* pixCur = (sour + y * pitch);
	//	for (int x = 1; x < width; ++x)
	//	{
	//		*d = (pixCur[0] + pixCur[1] + pixCur[2]) / 3;
	//		pixCur += 4;
	//		d++;
	//	}
	//}
	//d = m_hsv;
	//--height;
	//--width;
	//for (int y = 1; y < height; ++y)
	//{
	//	const uint8_t* pixCur = (sour + y * pitch) + channelCount + channelIndex;
	//	const uint8_t* pixPre = pixCur - pitch;
	//	const uint8_t* pixNex = pixCur + pitch;
	//	uint8_t* contour = (m_gradient + y * m_pitch) + 1;
	//	uint8_t* edge = (m_edge + y * m_pitch) + 1;
	//	uint8_t* angle = (m_angle + y * m_pitch);
	//	for (int x = 1; x < width; ++x)
	//	{
	//		//ʹ�� Sobel ����
	//		int32_t		sx = ((pixPre[channelCount] + pixCur[channelCount] * 2 + pixNex[channelCount]) - (pixPre[-channelCount] + pixCur[-channelCount] * 2 + pixNex[-channelCount]));
	//		int32_t		sy = ((pixPre[-channelCount] + pixPre[0] * 2 + pixPre[channelCount]) - (pixNex[-channelCount] + pixNex[0] * 2 + pixNex[channelCount]));
	//		int32_t		g = (int32_t)sqrt(sx * sx + sy * sy);
	//		*contour = g * 255 / 1140;	//��ֵ���Ƶ� 0~255.����1140��sqrt������ֵȡ����
	//		calcWidget(*contour, *edge, *angle, sx, sy);

	//		pixCur += channelCount;
	//		pixPre += channelCount;
	//		pixNex += channelCount;
	//		++contour;
	//		++edge;
	//		++angle;
	//	}
	//}

	//--height;
	//--width;
	//for (int y = 1; y < height; ++y)
	//{
	//	const uint8_t* pixCur = (sour + y * pitch) + channelCount + channelIndex;
	//	const uint8_t* pixPre = pixCur - pitch;
	//	const uint8_t* pixNex = pixCur + pitch;
	//	uint8_t* contour = (m_gradient + y * m_pitch) + 1;
	//	uint8_t* edge = (m_edge + y * m_pitch) + 1;
	//	uint8_t* angle = (m_angle + y * m_pitch);
	//	for (int x = 1; x < width; ++x)
	//	{
	//		//ʹ�� Sobel ����
	//		int32_t		sx = ((pixPre[channelCount] + pixCur[channelCount] * 2 + pixNex[channelCount]) - (pixPre[-channelCount] + pixCur[-channelCount] * 2 + pixNex[-channelCount]));
	//		int32_t		sy = ((pixPre[-channelCount] + pixPre[0] * 2 + pixPre[channelCount]) - (pixNex[-channelCount] + pixNex[0] * 2 + pixNex[channelCount]));
	//		int32_t		g = (int32_t)sqrt(sx * sx + sy * sy);
	//		*contour = g * 255 / 1140;	//��ֵ���Ƶ� 0~255.����1140��sqrt������ֵȡ����
	//		calcWidget(*contour, *edge, *angle, sx, sy);

	//		pixCur += channelCount;
	//		pixPre += channelCount;
	//		pixNex += channelCount;
	//		++contour;
	//		++edge;
	//		++angle;
	//	}
	//}
	return m_bkInfo;

}

void CleanBackground::blurHisTable(int32_t hisCount, uint32_t * sourTab, uint32_t * destTab, int32_t radius, bool isCricle)
{
	int32_t length = radius * 2 + 1;
	int32_t val = sourTab[0];
	if (isCricle)
	{
		for (int32_t i = 1; i <= radius; ++i)
		{
			val += sourTab[hisCount - i] + sourTab[i];
		}
		for (int32_t i = 0; i < hisCount; ++i)
		{
			destTab[i] = val / length;
			val = val - sourTab[(i - radius + hisCount) % hisCount] + sourTab[(i + radius + 1) % hisCount];
		}
	}
	else
	{
		for (int32_t i = 1; i <= radius; ++i)
		{
			val += sourTab[i];
		}
		for (int32_t i = 0; i < hisCount; ++i)
		{
			destTab[i] = val / ( length - max(radius - i, 0) - max(radius - (hisCount - 1 - i), 0) );
			if (i >= radius)
			{
				val -= sourTab[i - radius];
			}
			if ((hisCount - 1 - i) > radius)
			{
				val += sourTab[i + radius + 1];
			}
		}
	}
}

void CleanBackground::maxHisTable(int32_t hisCount, uint32_t* sourTab, uint32_t* destTab, int32_t radius, bool isCricle)
{
	int32_t length = radius * 2 + 1;
	uint32_t val = 0;
	if (isCricle)
	{

		for (int32_t i = 0; i < hisCount; ++i)
		{
			val = sourTab[i];
			for (int32_t t = 1; t <= radius; ++t)
			{
				val = max(val, max(sourTab[(i - t + hisCount) % hisCount] * (radius - t + 1 ) / radius, sourTab[(i + t) % hisCount] * (radius - t + 1) / radius ));
			}
			destTab[i] = val;
		}
	}
	else
	{
		for (int32_t i = 0; i < hisCount; ++i)
		{
			val = sourTab[i];
			for (int32_t t = 1; t <= radius; ++t)
			{
				val = max(val, max(sourTab[max(i - t, 0)] * (radius - t + 1) / radius, sourTab[min(i + t, hisCount - 1)] * (radius - t + 1) / radius));
			}
			destTab[i] = val;
		}
	}
}

CleanBackground::BkRange CleanBackground::beginRanged(uint16_t hisCount, uint32_t* hisTab)
{
	double	in = 0;
	double	out = 0;
	double	maxVariance = -1;
	int32_t	inCount = 0;
	int32_t	outCount = 0;
	BkRange	range = { 0, -1 };

	//��ֱ��ͼ��һ��ƽ��ģ��
	uint32_t	tab[256] = { 0 };
	blurHisTable(hisCount, hisTab, tab, 16, false);
	while (tab[hisCount - 1] < 8)
	{
		--hisCount;
	}
	if (hisCount < 1) return range;

	for (uint32_t i = 0; i < hisCount; ++i)
	{
		out += tab[i];
	}
	outCount = hisCount;
	hisCount /= 4;
	for (uint32_t i = 0; i < hisCount; ++i)
	{
		in += tab[i];
		out -= tab[i];
		++inCount;
		--outCount;

		double	ain = in / inCount;
		double	aout = out / outCount;
	
		double v = inCount * outCount * (ain - aout) * (ain - aout);
		if (v > maxVariance)
		{
			maxVariance = v;
			range.begin = 0;
			range.end = i;
		}

	}
	inCount = 16;
	while (inCount && range.end < hisCount && tab[range.end + 1] <= tab[range.end] + inCount)
	{
		--inCount;
		++range.end;
	}
	return range;
}

CleanBackground::BkRange CleanBackground::circleRanged(uint16_t hisCount, uint32_t* hisTab)
{
	double	count = 0;
	double	in = 0;
	double	out = 0;
	int32_t	inCount = 0;
	int32_t	outCount = 0;
	double	maxVariance = -1;
	uint16_t length = hisCount / 4;
	BkRange	range = { 0, -1 };


	//��ֱ��ͼ��һ��ƽ��ģ��
	uint32_t	tab[256] = { 0 };
	blurHisTable(hisCount, hisTab, tab, 16, true);
	//uint32_t* tab = hisTab;
	for (uint32_t i = 0; i < hisCount; ++i)
	{
		count += tab[i];
	}
	for (uint32_t s = 0; s < hisCount; ++s)
	{
		in = 0; out = count;
		inCount = 0; outCount = hisCount;
		for (uint32_t i = 0; i < length; ++i)
		{
			int32_t pos = (i + s) % hisCount;
			in += tab[pos];
			out -= tab[pos];
			++inCount;
			--outCount;

			double	ain = in * in / inCount;
			double	aout = out * out / outCount;
			if (ain > aout)
			{
				double v = double(inCount) * outCount * (ain - aout) * (ain - aout);
				if (v > maxVariance)
				{
					maxVariance = v;
					range.begin = s;
					range.end = pos;
				}
			}
		}
	}
	return range;
}
CleanBackground::BkRange CleanBackground::lineRanged(uint16_t hisCount, uint32_t* hisTab, bool asHue)
{
	double	count = 0;
	double	sum = 0;
	double	in = 0;
	double	out = 0;
	int32_t	inCount = 0;
	int32_t	outCount = 0;
	double	maxVariance = -1;
	BkRange	range = { 0, -1 };


	//uint32_t* tab = hisTab;
	//��ֱ��ͼ��һ��ƽ��ģ��
	uint32_t	tab[256] = { 0 };
	blurHisTable(hisCount, hisTab, tab, 16, false);
	uint16_t length = hisCount;
	uint16_t front = 0;
	hisTab = tab;
	while (*hisTab < 8)
	{
		++hisTab;
		--length;
		++front;
	}
	if (length < 1) return range;
	while (hisTab[length - 1] < 8)
	{
		--length;
	}
	if (length < 1) return range;

	for (uint32_t i = 0; i < length; ++i)
	{
		count += hisTab[i];
	}
	if (asHue)
	{
		for (uint32_t s = 0; s < length; ++s)
		{
			in = 0; out = count;
			inCount = 0; outCount = length;
			for (uint16_t i = 0; i < length - s; ++i)
			{
				in += hisTab[i + s];
				out -= hisTab[i + s];
				++inCount;
				--outCount;

				double	ain = in * in / inCount;
				double	aout = out * in / outCount;
				if (ain > aout)
				{
					double v = inCount * outCount * (ain - aout) * (ain - aout);
					if (v > maxVariance)
					{
						maxVariance = v;
						range.begin = s + front;
						range.end = i + s + front;
					}
				}
			}
		}
	}
	else
	{
		for (uint32_t s = 0; s < length; ++s)
		{
			in = 0; out = count;
			inCount = 0; outCount = length;
			for (uint16_t i = 0; i < length - s; ++i)
			{
				in += hisTab[i + s];
				out -= hisTab[i + s];
				++inCount;
				--outCount;

				double	ain = in / inCount;
				double	aout = out / outCount;
				if (ain > aout)
				{
					double v = inCount * outCount * (ain - aout) * (ain - aout);
					if (v > maxVariance)
					{
						maxVariance = v;
						range.begin = s + front;
						range.end = i + s + front;
					}
				}
			}
		}
	}

	inCount = range.begin;
	while (inCount && tab[inCount - 1] <= tab[range.begin])
	{
		--inCount;
	}
	inCount += (range.begin - inCount) / 3;
	if (inCount != range.begin)
		range.begin = otsuHistogram(range.begin - inCount + 1, tab + inCount) + inCount + 1;

	inCount = range.end;
	while (inCount < hisCount - 1 && tab[inCount + 1] <= tab[range.end])
	{
		++inCount;
	}
	inCount -= (inCount - range.end) / 3;
	if (inCount != range.end)
		range.end = otsuHistogram(inCount - range.end + 1, tab + range.end) + range.end;


	return range;
}

int32_t	CleanBackground::otsuHistogram(int32_t hisCount, uint32_t* hisTab)
{
	uint64_t	sumLeft = 0;
	uint32_t	countLeft = 0;
	uint64_t	sumRight = 0;
	uint32_t	countRight = 0;
	double		maxVariance = -1;
	int32_t		thresholdVal = 0;

	for (int32_t i = 0; i < hisCount; ++i)
	{
		sumRight += hisTab[i] * i;
		countRight += hisTab[i];
	}
	--hisCount;
	for (int32_t i = 0; i < hisCount; ++i)
	{
		sumLeft += hisTab[i] * i;
		countLeft += hisTab[i];
		sumRight -= hisTab[i] * i;
		countRight -= hisTab[i];
		if (sumLeft == 0) continue;
		else if (sumRight == 0) break;
		double	avgLeft = (double)sumLeft / countLeft;
		double	avgRight = (double)sumRight / countRight;
		double	variance = (double)countLeft * countRight * (avgLeft - avgRight) * (avgLeft - avgRight);
		if (variance > maxVariance)
		{
			maxVariance = variance;
			thresholdVal = i;
		}
	}
	return thresholdVal;

}

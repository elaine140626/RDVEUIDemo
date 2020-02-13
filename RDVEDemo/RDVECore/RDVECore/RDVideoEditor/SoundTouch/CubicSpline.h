#ifndef CCUBICSPLINE_H
#define CCUBICSPLINE_H
#include <vector>
using namespace std;


//��������
class CCubicSpline
{
public:
	CCubicSpline();
	~CCubicSpline();

	//��ṹ
	struct SPoint
	{
	public:
		float	x;
		float	y;
		float	m;
		bool	bSharp;		//�����
		SPoint()
		{
			x	= 0.0;
			y	= 0.0;
			bSharp	= false;
			m	= 0.0;
		}
		SPoint( float dX, float dY, bool bIsSharp = false )
		{
			x	= dX;
			y	= dY;
			bSharp	= bIsSharp;
			m	= 0.0;
		}
	};
	int32_t		GetKeyPointCount() const { return m_poKeyPoints.size(); }
	SPoint	GetKeyPointInfo( int32_t iIndex ) const {	return m_poKeyPoints[iIndex]; }

	//����㣬�������������ֵ��Χ����ô dX �� dY ����Ч��Χ��Ϊ 0~1��
	//�ɹ�����������ʧ�ܷ���-1����� dX �Ѿ����ڣ����޸� y ֵ�������������š�
	int32_t	InsertPoint( float dX, float dY );
	//���õ��״̬����ƽ�����߻��Ǽ���ġ�
	bool SetPointSharp( int32_t iIndex, bool bIsSharp );
	bool SetPointPos( int32_t iIndex, float dX, float dY );
	//ɾ����
	bool RemovePoint( int32_t iIndex );
	//ָ�� x ���ϵ����꣬ȡ�������� y ���ϵ�ֵ��
	float GetCurveValue( float dX );

	void SetPoints( vector<SPoint>& sPoints );

	void SetEndpointProperty( bool bEndpointExtension, bool bLimitValueRange )
	{
		m_bEndpointExtension	= bEndpointExtension;
		m_bLimitValueRange		= bLimitValueRange;
	}
protected:
	bool			m_bEndpointExtension;	//�˵����죬true ��ʾ�˵��� y=0 ��������ߡ�
	bool			m_bLimitValueRange;		//�ѷ��ص�ֵ���Ƶ� 0~1 ֮��
	vector<SPoint>	m_poKeyPoints;
	//�������ߵĸ���ϵ����
	void Coefficient();
};

#endif // CCUBICSPLINE_H
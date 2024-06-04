*<<<<<<<<<<<<<>>>>>>>>>>>>>
Function	Fig2Word(iAmount)
*<<<<<<<<<<<<<>>>>>>>>>>>>>
//----------------------------------------------------------
// Parameters	: 1. INTEGER to be expressed in words
// Description : One of the many
// Calls		: None
// Caveats	: Can handle only amounts less than a crore
// Returns	: the String
//----------------------------------------------------------
Local	sAmount	:=	AllTrim(Str(iAmount))
Local	iSize, 	sRetWords, sTempWords
Local i, j, iNdxVar
Static	asUnits	:=	{						;
					[One ], [Two ], [Three ],;
					[Four ], [Five ], [Six ], [Seven ],;
					[Eight ], [Nine ], [Ten ], [Eleven ],;
					[Twelve ], [Thirteen ], [Fourteen ],;
					[Fifteen ], [Sixteen ], [Seventeen ],;
					[Eighteen ], [Nineteen ], [Twenty ]; 
					}
Static	asTens	:=	{							;
					[Ten ], [Twenty ], [Thirty ],;
					[Forty ], [Fifty ], [Sixty ], [Seventy ],;
					[Eighty ], [Ninety ]		;
					}

Static	asPowers	:=	{ [Lakh ], [Thousand ], [Hundred ], []}
Static	aiPowers	:=	{ 100000, 1000, 100, 1}
//----------------------------------------------------------
iSize	:=	Len(sAmount)
If iSize > 2
	sAmount	:=	IIf(iSize % 2 == 0, [0], []) +			;
				SubStr(sAmount, 1, iSize - 3) +			;
				[0] + 								;
				SubStr(sAmount, iSize - 2, 3)
Else
	sAmount 	:=	Iif(iSize % 2 == 0, [], [0]) +			;
				sAmount
Endif
iSize	:=	Len(sAmount)
sAmount	:=	[00000000] + sAmount
sAmount	:=	SubStr(sAmount, iSize+1, 8)
iSize := 8
sRetWords	:=	[]
i	:=	j	:=	1
For	i	:=	1	to	iSize	Step	2
// Do	While	i < iSize
	sTempWords	:=	[]
	iNdxVar	:=	Val(SubStr(sAmount, i, 2))
	If	iNdxVar	<	20
		if iNdxVar > 0
			sTempWords	:=	asUnits[iNdxVar]
		Endif
	Else
		if (iNdxVar / 10) > 0
			sTempWords	:=	asTens[Int(iNdxVar / 10)]
		Endif
		if (iNdxvar % 10) > 0
			sTempWords	:= sTempWords + asUnits[(iNdxVar % 10)]
		Endif
	EndIf
	If	!Empty(sTempWords)
		sRetWords	:=	sRetWords + sTempWords +  asPowers[j]
	EndIf
//	i++
//	i++
	if	j == 3	.And.	!Empty(sTempWords)		// Hundreds
		If SubStr(sAmount, 7, 2)	!= [00]
			sRetWords	:= sRetWords + [and ]
		Endif
	Endif
	j++
	
// EndDo	
Next
Return	sRetWords
**************************************************************************
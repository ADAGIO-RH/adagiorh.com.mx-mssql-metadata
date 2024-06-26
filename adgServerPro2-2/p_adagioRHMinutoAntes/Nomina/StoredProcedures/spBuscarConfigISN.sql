USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Nomina.spBuscarConfigISN
(
	@IDConfigISN int = null
)
AS
BEGIN
	Select 
		ISN.IDConfigISN
		, ISN.IDEstado  as IDEstado
		, Est.Descripcion as Estado
		, Isnull(ISN.Porcentaje,0) as Porcentaje
		, ISN.IDConceptos
		,Conceptos = ISNULL( STUFF(  
				   (   SELECT ', ['+ cast(Codigo as varchar(10))+'] '+ CONVERT(NVARCHAR(100), Descripcion)   
					FROM Nomina.tblCatConceptos  
					WHERE IDConcepto in (select cast(rtrim(ltrim(item)) as int) from app.Split(ISN.IDConceptos,','))  
					ORDER BY OrdenCalculo  asc  
					FOR xml path('')  
				   )  
				   , 1  
				   , 1  
				   , ''), 'Conceptos no definidos')   
		, ROW_NUMBER() over(Order by ISN.IDConfigISN asc) as ROWNUMBER
	from Nomina.tblConfigISN ISN
		inner join STPS.tblCatEstados Est
			on Est.IDEstado = ISN.IDEstado
	where (ISN.IDConfigISN = @IDConfigISN) or(ISNULL(@IDConfigISN,0) = 0 ) 
END
GO

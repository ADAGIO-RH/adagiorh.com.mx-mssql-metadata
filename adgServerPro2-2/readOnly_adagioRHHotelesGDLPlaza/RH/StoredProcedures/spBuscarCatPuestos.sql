USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatPuestos]    
(    
 @IDPuesto int = null  
 ,@IDUsuario int = null     
)    
AS    
BEGIN    
	SET FMTONLY OFF;  
  
	IF OBJECT_ID('tempdb..#TempPuestos') IS NOT NULL DROP TABLE #TempPuestos  
  
	select ID   
	Into #TempPuestos  
	from Seguridad.tblFiltrosUsuarios   
	where IDUsuario = @IDUsuario and Filtro = 'Puestos'  
  
	SELECT     
		p.IDPuesto    
		,p.Codigo    
		,p.Descripcion    
		,p.DescripcionPuesto    
		,isnull(p.SueldoBase,0) as SueldoBase    
		,isnull(p.TopeSalarial,0) as TopeSalarial    
		,p.NivelSalarial    
		,isnull(p.IDOcupacion,0) as IDOcupacion    
		,'['+o.Codigo+'] - '+o.Descripcion as Ocupacion    
	FROM [RH].[tblCatPuestos] p    
		left join STPS.tblCatOcupaciones O    
			on P.IDOcupacion = o.IDOcupaciones    
	WHERE (P.IDPuesto = @IDPuesto or @IDPuesto is NULL)    
		and (IDPuesto in  ( select ID from #TempPuestos)  
		OR Not Exists(select ID from #TempPuestos))  
	ORDER BY P.Descripcion ASC    
END
GO

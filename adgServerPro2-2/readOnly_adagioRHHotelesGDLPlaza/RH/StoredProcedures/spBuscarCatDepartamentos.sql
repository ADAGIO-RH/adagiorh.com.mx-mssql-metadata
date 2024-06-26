USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [RH].[spBuscarCatDepartamentos]    
(    
 @Departamento Varchar(max) = null  
 ,@IDUsuario int = null    
)    
AS    
BEGIN    
	SET FMTONLY OFF;
	IF OBJECT_ID('tempdb..#TempDepartamentos') IS NOT NULL DROP TABLE #TempDepartamentos  
  
	select ID   
	Into #TempDepartamentos  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'Departamentos'  
  
	SELECT     
		IDDepartamento    
		,Codigo    
		,Descripcion    
		,CuentaContable    
		,isnull(IDEmpleado,0) as IDEmpleado    
		,JefeDepartamento     
		--,ROW_NUMBER()OVER(ORDER BY IDDepartamento ASC)  AS ROWNUMBER    
	FROM [RH].[tblCatDepartamentos] with(nolock)     
	WHERE (Codigo LIKE @Departamento+'%') OR (Descripcion LIKE @Departamento+'%') OR (@Departamento IS NULL)    
		and (IDDepartamento in (select ID from #TempDepartamentos)  
		OR Not Exists(select ID from #TempDepartamentos))  
	ORDER BY Descripcion ASC    
END
GO

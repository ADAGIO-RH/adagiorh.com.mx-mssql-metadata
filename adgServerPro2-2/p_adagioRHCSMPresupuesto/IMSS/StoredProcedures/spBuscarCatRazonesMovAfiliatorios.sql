USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatRazonesMovAfiliatorios]
(
	@IDRazonMovimiento int = null
    ,@IDTipoMovimiento int = null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN


	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  

    if (@IDTipoMovimiento is null)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
		WHERE  (@query = '""' or contains(*, @query))

    end;

    if (@IDTipoMovimiento  = 1)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE Alta=1
		and  (@query = '""' or contains(*, @query))
    end;

    if (@IDTipoMovimiento  = 2)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE Baja=1
		and  (@query = '""' or contains(*, @query))
    end;

    if (@IDTipoMovimiento  = 3)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE ReIngreso=1 
		and  (@query = '""' or contains(*, @query))
    end;

    if (@IDTipoMovimiento  = 4)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE MovSueldo=1
		and  (@query = '""' or contains(*, @query))
    end;

END
GO

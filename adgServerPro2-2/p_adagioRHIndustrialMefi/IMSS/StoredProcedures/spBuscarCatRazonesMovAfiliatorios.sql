USE [p_adagioRHIndustrialMefi]
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
			 R.IDRazonMovimiento
			,R.Codigo
			,R.Descripcion
			,R.Alta
			,R.Baja
			,R.ReIngreso
			,R.MovSueldo
			,ISNULL(T.IDCatTipoRazonMovimiento,0) as IDCatTipoRazonMovimiento
			,T.Codigo as CodigoTipoRazonMovimiento
			,T.Descripcion as DescripcionTipoRazonMovimiento
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios R WITH(NOLOCK)
			Left Join Imss.tblCatTiposRazonesMovimientos T With(Nolock)
				on R.IDCatTipoRazonMovimiento = T.IDCatTipoRazonMovimiento
		WHERE  (R.IDRazonMovimiento = @IDRazonMovimiento OR isnull(@IDRazonMovimiento,0) = 0)
            and (@query = '""' or contains(R.*, @query))

    end;

    if (@IDTipoMovimiento  = 1)
    begin
	   		
		SELECT 
			 R.IDRazonMovimiento
			,R.Codigo
			,R.Descripcion
			,R.Alta
			,R.Baja
			,R.ReIngreso
			,R.MovSueldo
			,ISNULL(T.IDCatTipoRazonMovimiento,0) as IDCatTipoRazonMovimiento
			,T.Codigo as CodigoTipoRazonMovimiento
			,T.Descripcion as DescripcionTipoRazonMovimiento
			,ROW_NUMBER()over(ORDER BY R.IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios R WITH(NOLOCK)
			Left Join Imss.tblCatTiposRazonesMovimientos T With(Nolock)
				on R.IDCatTipoRazonMovimiento = T.IDCatTipoRazonMovimiento
	    WHERE R.Alta=1
		and  (@query = '""' or contains(R.*, @query))
    end;

    if (@IDTipoMovimiento  = 2)
    begin
	   SELECT 
			 R.IDRazonMovimiento
			,R.Codigo
			,R.Descripcion
			,R.Alta
			,R.Baja
			,R.ReIngreso
			,R.MovSueldo
			,ISNULL(T.IDCatTipoRazonMovimiento,0) as IDCatTipoRazonMovimiento
			,T.Codigo as CodigoTipoRazonMovimiento
			,T.Descripcion as DescripcionTipoRazonMovimiento
			,ROW_NUMBER()over(ORDER BY R.IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios R WITH(NOLOCK)
			Left Join Imss.tblCatTiposRazonesMovimientos T With(Nolock)
				on R.IDCatTipoRazonMovimiento = T.IDCatTipoRazonMovimiento
	    WHERE R.Baja=1
		and  (@query = '""' or contains(R.*, @query))
    end;

    if (@IDTipoMovimiento  = 3)
    begin
	    SELECT 
			 R.IDRazonMovimiento
			,R.Codigo
			,R.Descripcion
			,R.Alta
			,R.Baja
			,R.ReIngreso
			,R.MovSueldo
			,ISNULL(T.IDCatTipoRazonMovimiento,0) as IDCatTipoRazonMovimiento
			,T.Codigo as CodigoTipoRazonMovimiento
			,T.Descripcion as DescripcionTipoRazonMovimiento
			,ROW_NUMBER()over(ORDER BY R.IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios R WITH(NOLOCK)
			Left Join Imss.tblCatTiposRazonesMovimientos T With(Nolock)
				on R.IDCatTipoRazonMovimiento = T.IDCatTipoRazonMovimiento
	    WHERE R.ReIngreso=1 
		and  (@query = '""' or contains(R.*, @query))
    end;

    if (@IDTipoMovimiento  = 4)
    begin
	   SELECT 
			 R.IDRazonMovimiento
			,R.Codigo
			,R.Descripcion
			,R.Alta
			,R.Baja
			,R.ReIngreso
			,R.MovSueldo
			,ISNULL(T.IDCatTipoRazonMovimiento,0) as IDCatTipoRazonMovimiento
			,T.Codigo as CodigoTipoRazonMovimiento
			,T.Descripcion as DescripcionTipoRazonMovimiento
			,ROW_NUMBER()over(ORDER BY R.IDRazonMovimiento)as ROWNUMBER 
		FROM IMSS.tblCatRazonesMovAfiliatorios R WITH(NOLOCK)
			Left Join Imss.tblCatTiposRazonesMovimientos T With(Nolock)
				on R.IDCatTipoRazonMovimiento = T.IDCatTipoRazonMovimiento
	    WHERE R.MovSueldo=1
		and  (@query = '""' or contains(R.*, @query))
    end;

END
GO

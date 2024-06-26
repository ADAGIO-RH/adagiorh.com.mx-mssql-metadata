USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Norma35].[spBuscarDenuncias] 
	-- Add the parameters for the stored procedure here
	@IDUsuario int =0
    ,@IDTipoDenuncia int= 0
    ,@IDTipoDenunciado int =0
    ,@FechaInicio DATE =null
    ,@FechaFin DATE =null
    ,@IDEstatusDenuncia  int =0
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query		varchar(max) = ''
AS
BEGIN
    declare      @TotalPaginas int = 0 
                ,@TotalRegistros decimal(18,2) = 0.00 ;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempDenuncias') is not null drop table #tempDenuncias;

    select 	de.IDDenuncia
			,denuncias.Descripcion as [TipoDenunciaDescripcion]  
			,estd.Descripcion as  [EstatusDescripcion]
			,estd.EstatusColor
			,estd.EstatusBackground 			
			,de.EsAnonima
            ,de.IDTipoDenuncia
            ,de.IDEmpleadoDenunciante 			
			,de.FechaEvento
			,de.FechaRegistro		
    INTO #tempDenuncias	
	FROM Norma35.tblDenuncias as de	
	LEFT JOIN [Norma35].[tblCatEstatusDenuncia] as estd on estd.IDEstatusDenuncia=de.IDEstatusDenuncia	
	LEFT JOIN Norma35.tblCatTiposDenuncias denuncias on denuncias.IDTipoDenuncia=de.IDTipoDenuncia
	where 
        ([de].IDEstatusDenuncia = @IDEstatusDenuncia or isnull(@IDEstatusDenuncia,0) = 0) and
    
		(coalesce(@query,'') = '' or coalesce(de.DescripcionHechos, '') like '%'+@query+'%')
        

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempDenuncias

	select @TotalRegistros = cast(COUNT([IDDenuncia]) as decimal(18,2)) from #tempDenuncias		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempDenuncias
		order by [IDTipoDenuncia] asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


	 
END
GO

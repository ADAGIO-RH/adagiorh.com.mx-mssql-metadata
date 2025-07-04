USE [p_adagioRHIndustrialMefi]
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
CREATE PROCEDURE [App].[spBuscarRespaldoReporteTRDP]	
	@IDUsuario int null
    ,@IDReporteBasico int null	
    ,@IDSubreporte int null
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query		varchar(max) = ''

AS
BEGIN

    Declare @TotalPaginas int = 0 
            ,@TotalRegistros decimal(18,2) = 0.00 ;

 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempRespaldoReporteTRDP') is not null drop table #tempRespaldoReporteTRDP;


        SELECT IDReporteBasico, IDRespaldoReportesTRDP,Notas , rr.IDUsuario,rr.FechaRegistro,rr.RutaRespaldo ,concat(us.Nombre ,' ',us.Apellido) as NombreCompletoUsuario
        into #tempRespaldoReporteTRDP
        from App.tblRespaldoReportesTRDP as rr

        INNER JOIN Seguridad.tblUsuarios as us on us.IDUsuario=rr.IDUsuario

        WHERE IDReporteBasico= @IDReporteBasico
        and    (rr.IDUsuario = @IDUsuario or isnull(@IDUsuario,0) = 0)  
        and  (   rr.IDSubreporte=@IDSubreporte or    rr.IDSubreporte is null) 
		and (coalesce(@query,'') = '' or coalesce(rr.Notas, '') like '%'+@query+'%')


    
    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempRespaldoReporteTRDP

	select @TotalRegistros = cast(COUNT([IDRespaldoReportesTRDP]) as decimal(18,2)) from #tempRespaldoReporteTRDP		
	
    
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end

	from #tempRespaldoReporteTRDP
		order by [FechaRegistro] desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

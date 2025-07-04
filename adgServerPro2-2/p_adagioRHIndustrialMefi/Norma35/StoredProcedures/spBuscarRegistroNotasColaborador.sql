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
CREATE PROCEDURE [Norma35].[spBuscarRegistroNotasColaborador]
	-- Add the parameters for the stored procedure here
	@IDUsuario int 
    ,@IDRegistroNotasColaborador int
    ,@IDEmpleado int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query		varchar(max) = ''
AS
BEGIN
	
    declare      @TotalPaginas int = 0 
                ,@TotalRegistros decimal(18,2) = 0.00 ;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempBuscarRegistroNotasColaborador') is not null drop table #tempBuscarRegistroNotasColaborador;


    select 
        IDRegistroNotasColaborador 
        ,r.IDEmpleado
        ,Titulo 
        ,Notas,FechaRegistro 
        ,r.IDUsuarioRegistro  
        ,t.Nombre  [NombreUsuarioRegistro]
        into #tempBuscarRegistroNotasColaborador
    from Norma35.tblRegistroNotasColaborador r 
    left join Seguridad.tblUsuarios t on r.IDUsuarioRegistro=t.IDUsuario 
    where 
        r.IDEmpleado = @IDEmpleado and 
        (r.IDRegistroNotasColaborador = @IDRegistroNotasColaborador or isnull(@IDRegistroNotasColaborador,0)=0)

        and (coalesce(@query,'') = '' or coalesce(r.Titulo, '') like '%'+@query+'%' or coalesce(r.Notas, '') like '%'+@query+'%')
        

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempBuscarRegistroNotasColaborador

	select @TotalRegistros = cast(COUNT([IDRegistroNotasColaborador]) as decimal(18,2)) from #tempBuscarRegistroNotasColaborador		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempBuscarRegistroNotasColaborador
		order by [FechaRegistro] asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

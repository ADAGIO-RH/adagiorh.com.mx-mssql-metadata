USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarCatReportesBasicosWP] (
	@IDReporteBasico int = 0
	,@IDAplicacion nvarchar(100) = null
	,@Personalizado bit = null
    ,@Privado bit=null
	,@IDUsuario int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query		varchar(max) = ''
) as

Declare @TotalPaginas int = 0 
            ,@TotalRegistros decimal(18,2) = 0.00 ;

 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCatReportesBasicosWP') is not null drop table #tempCatReportesBasicosWP;

	select IDReporteBasico
		  ,IDAplicacion
		  ,upper(Nombre)		as Nombre
		  ,upper(Descripcion)	as Descripcion
		  ,NombreReporte
          ,(Select top 1 RutaRespaldo from app.tblRespaldoReportesTRDP s where s.IDReporteBasico= rb.IDReporteBasico and s.RutaRespaldo LIKE '%.docx'  order by IDRespaldoReportesTRDP desc) as NombreDocx
		  ,ConfiguracionFiltros
		  ,Grupos
		  ,NombreProcedure
		  ,isnull(Personalizado,0) as Personalizado
          ,isnull(Privado,0) as Privado
          ,(select count(s.IDRespaldoReportesTRDP) from app.tblRespaldoReportesTRDP s where s.IDReporteBasico= rb.IDReporteBasico and s.RutaRespaldo LIKE '%.trdp') as HasFiles 
          , 0 as HasTrdp 
          , (select count(s.IDRespaldoReportesTRDP) from app.tblRespaldoReportesTRDP s where s.IDReporteBasico= rb.IDReporteBasico and s.RutaRespaldo LIKE '%.docx') as HasDocx        
          , (select count(s.IDSubreporte) from Reportes.tblCatReportesBasicosSubReportes s where s.IDReporteBasico= rb.IDReporteBasico) as HasSubreports 
		  ,ROW_NUMBER()OVER(ORDER BY IDReporteBasico ASC) as ROWNUMBER 
    into #tempCatReportesBasicosWP
	from Reportes.tblCatReportesBasicos rb with (nolock) 
	where (IDReporteBasico = @IDReporteBasico or  ISNULL(@IDReporteBasico,0) = 0 ) 
	  and (IDAplicacion = @IDAplicacion or (@IDAplicacion is null or @IDAplicacion ='0') )
	  and (isnull(Personalizado,0) = @Personalizado or @Personalizado is null)
      and (isnull(Privado,0) = @Privado or @Privado is null)
      and (coalesce(@query,'') = '' or coalesce(Nombre, '') like '%'+@query+'%')

    update #tempCatReportesBasicosWP set HasFiles = case when HasFiles>0 then  1  else  0  end ,
                                         HasDocx = case when HasDocx>0 then  1  else  0  end ,
                                         HasSubreports= case when HasSubreports>0 then  1  else  0  end ,
                                         HasTrdp = case when  HasFiles>0 then   1  else 
                                                                                        case when isnull(NombreReporte,'') ='' then 0 else 1 end
                                                                                   end
	
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatReportesBasicosWP

	select @TotalRegistros = cast(COUNT([IDReporteBasico]) as decimal(18,2)) from #tempCatReportesBasicosWP		
	
    
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end

	from #tempCatReportesBasicosWP
		order by [IDAplicacion],[Nombre]  asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

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
-- [Norma35].[spBuscarDenuncias] @IDUsuario = 1
-- =============================================
CREATE PROCEDURE [Norma35].[spBuscarDenuncias] 
    @IDDenuncia int = 0
	,@IDTipoDenuncia int= 0
    ,@IDTipoDenunciado int =0
	,@IDEmpleadoDenunciante int = 0
    ,@FechaInicio DATETIME ='1900-01-01'
    ,@FechaFin DATETIME ='9999-12-31'
    ,@IDEstatusDenuncia  int =0
	,@IDUsuario int =0
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaRegistro'
	,@orderDirection varchar(4) = 'asc'
AS
BEGIN
   SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaRegistro' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
		,@FechaInicio = case when @FechaInicio IS null or ISNULL(@FechaInicio,'') = '' THEN '1900-01-01' ELSE @FechaInicio END
		,@FechaFin = case when @FechaFin IS null or ISNULL(@FechaFin,'') = '' THEN '9999-12-31' else @FechaFin end

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	if object_id('tempdb..#tempDenuncias') is not null drop table #tempDenuncias;

    select 
		de.IDDenuncia
		,tiposdenuncia.Descripcion as [TipoDenunciaDescripcion]  
		,estd.Descripcion as  [EstatusDescripcion]
		,estd.EstatusColor
		,estd.EstatusBackground 			
		,de.EsAnonima
        ,de.IDTipoDenuncia
        ,de.IDEmpleadoDenunciante 			
		,de.FechaEvento
		,de.FechaRegistro,
		CASE 
			WHEN de.IDTipoDenunciado = 1 /*DENUNCIAR UNA SITUACIÓN EN ESPECÍFICO.*/ THEN ('EVENTO: ' + UPPER(de.Denunciados) )
			WHEN de.IDTipoDenunciado = 2 /*DENUNCIAR A UN COLABORADOR.*/			THEN (select CONCAT(emp.Nombre,' ',emp.Paterno) from RH.tblEmpleados  emp where IDEmpleado = cast(de.Denunciados as int))
			WHEN de.IDTipoDenunciado = 3 /*DENUNCIAR A VARIOS COLABORADORES..*/		THEN ( select distinct  
																								stuff((
																									select ',' + CONCAT(emp.Nombre,' ',emp.Paterno)
																									from RH.tblEmpleados emp
																									where emp.IDEmpleado in ( SELECT item from [App].[Split](de.Denunciados,',') )
																									order by emp.IDEmpleado
																									for xml path('')
																								),1,1,'')
																							from RH.tblEmpleados
																							group by IDEmpleado
																						)
		END AS Titulo ,
        ed.IDEmpleado  [EmpleadoDenuncianteIDEmpleado] ,
        ed.NOMBRECOMPLETO [EmpleadoDenuncianteNombreCompleto] ,
        ed.Departamento [EmpleadoDenuncianteDepartamento],
        ed.ClaveEmpleado [EmpleadoDenuncianteClaveEmpleado],

        edd.IDEmpleado     [EmpleadoDenunciadoIDEmpleado] ,
        edd.NOMBRECOMPLETO [EmpleadoDenunciadoNombreCompleto] ,
        edd.Departamento   [EmpleadoDenunciadoDepartamento],
		edd.ClaveEmpleado  [EmpleadoDenunciadoClaveEmpleado],
		EmpleadoDenunciante = (
			select 
				eD.IDEmpleado,
				eD.ClaveEmpleado,
				eD.NOMBRECOMPLETO as NombreCompleto,
				eD.Departamento,
				eD.Sucursal,
				eD.Puesto
			from RH.tblEmpleadosMaster eD
			where eD.IDEmpleado = de.IDEmpleadoDenunciante 
			for json auto, without_array_wrapper
		)
    INTO #tempDenuncias	
	FROM Norma35.tblDenuncias  as de	with(nolock)
		LEFT JOIN [Norma35].[tblCatEstatusDenuncia] as estd with(nolock) on estd.IDEstatusDenuncia=de.IDEstatusDenuncia	
		LEFT JOIN [RH].tblEmpleadosMaster as ed with(nolock) on ed.IDEmpleado = de.IDEmpleadoDenunciante
		LEFT JOIN Norma35.tblCatTiposDenuncias tiposdenuncia with(nolock) on tiposdenuncia.IDTipoDenuncia=de.IDTipoDenuncia and de.IDTipoDenunciado in (2,3) 
		LEFT JOIN RH.tblEmpleadosMaster as edd with(nolock) on edd.IDEmpleado = (
			SELECT TOP 1 item
			FROM App.Split(IIF(de.IDTipoDenunciado IN (2,3), de.Denunciados, ''), ',')
		) AND de.IDTipoDenunciado IN (2,3)
		LEFT JOIN Seguridad.tblUsuarios u with (nolock) on ed.IDEmpleado = u.IDEmpleado             
	where ([de].IDDenuncia = @IDDenuncia or isnull(@IDDenuncia,0) = 0) and
        ([de].IDEstatusDenuncia = @IDEstatusDenuncia or isnull(@IDEstatusDenuncia,0) = 0) and
        ([de].IDTipoDenuncia = @IDTipoDenuncia or isnull(@IDTipoDenuncia,0) = 0) and
        ([de].IDTipoDenunciado = @IDTipoDenunciado or isnull(@IDTipoDenunciado,0) = 0) and
        ( 
			([de].FechaRegistro BETWEEN @FechaInicio  and @FechaFin   or isnull(@FechaInicio,'1900-01-01') = '1900-01-01')  or 
			([de].FechaEvento BETWEEN @FechaInicio  and @FechaFin   or isnull(@FechaInicio,'9999-12-31') = '9999-12-31') 
		) 
			and   
		([de].IDEmpleadoDenunciante = @IDEmpleadoDenunciante or isnull(@IDEmpleadoDenunciante,0) = 0) 
			and
		  (@query = '""' or contains(de.*, @query) 
		  or contains(estd.*, @query) 
		  or contains(edd.*, @query) 
		  or contains(tiposdenuncia.*, @query)) 

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempDenuncias

	select @TotalRegistros = cast(COUNT([IDDenuncia]) as decimal(18,2)) from #tempDenuncias		
	
	select 	
		*
		, TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		, @TotalRegistros as TotalRegistros
	from #tempDenuncias
	order by 
		case when @orderByColumn = 'FechaRegistro'			and @orderDirection = 'asc'		then FechaRegistro end,			
		case when @orderByColumn = 'FechaRegistro'			and @orderDirection = 'desc'	then FechaRegistro end desc,		
		FechaRegistro asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
 	 
END
GO

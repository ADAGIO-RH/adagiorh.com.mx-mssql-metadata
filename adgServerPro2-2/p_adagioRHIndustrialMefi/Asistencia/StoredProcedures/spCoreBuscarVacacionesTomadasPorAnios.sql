USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Calcula el historial de saldos de vacaciones de un colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  
[Asistencia].[spBuscarVacacionesTomadasPorAnios] 390,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  
CREATE proc [Asistencia].[spCoreBuscarVacacionesTomadasPorAnios] --390,1
(  
  @IDUsuario int  
  ,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY
) as  
  
	SET FMTONLY OFF;  
  
	declare   
	  
		@FechaAntiguedad date  
		,@FechaIni date = getdate()  
		,@FechaFin date = getdate()  
		,@IDTipoPrestacion int  
		,@IDCliente int  
		,@AniosAntiguedad float = 0  
		,@VacacionesCaducanEn float = 0  
		,@MaxAnio int = 0  
		,@IDEmpleado int = 0			  
	    ,@orderByColumn	varchar(50) = 'Anio'
	    ,@orderDirection varchar(4) = 'asc' 
        ,@IDIdioma varchar(20)
		,@traduccionYESNO varchar(500) = N'
			{
				"esmx": {
					"SI": "SI",
					"NO": "NO"
				},
				"enus": {
					"SI": "YES",
					"NO": "NO"
				}
			}
		'
	;  
  
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	;  
  
	if object_id('tempdb..#tempSetPagination') is not null drop table #tempSetPagination;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  
		    
    	        
    Select  @orderByColumn=isnull(Value,'Anio') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'    

    SET @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)  
  
	select   
		@FechaAntiguedad	= isnull(e.FechaAntiguedad,getdate())  
		,@IDTipoPrestacion	= pe.IDTipoPrestacion  
		,@IDCliente			= ce.IDCliente  
	from [RH].[tblEmpleadosMaster] e with (nolock)  
		LEFT JOIN [RH].[tblPrestacionesEmpleado] pe with (nolock) ON pe.IDEmpleado = e.IDEmpleado   
			and pe.FechaIni<= @Fechafin and pe.FechaFin >= @Fechafin  
		LEFT JOIN [RH].tblClienteEmpleado ce with (nolock) ON ce.IDEmpleado = e.IDEmpleado   
			and ce.FechaIni<= @Fechafin and ce.FechaFin >= @Fechafin     
	where e.IDEmpleado = @IDEmpleado  
  
   --select @FechaAntiguedad,@IDTipoPrestacion  
  
	if exists (select top 1 1  
				from RH.[TblConfiguracionesCliente] with (nolock)   
				where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn')  
	begin  
		select top 1 @VacacionesCaducanEn = cast(isnull(Valor,0.0) as Float)  
		from RH.[TblConfiguracionesCliente] with (nolock)   
		where IDCliente = @IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'  
	end else   
	begin  
		set @VacacionesCaducanEn = 12775;  
	end;  
      
	SELECT @AniosAntiguedad = DATEDIFF(day,@FechaAntiguedad,getdate()) / 365.2425  
  
	if not exists (select top 1 1   
					 from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					 where IDTipoPrestacion = @IDTipoPrestacion 
						and Antiguedad = case when @AniosAntiguedad < 1 then 1 else cast(@AniosAntiguedad as int) end)  
	begin  
		exec app.spObtenerError  @IDUsuario= @IDUsuario,@CodigoError='0410002'  
		return  
	end;  
  
 --  select @AniosAntiguedad  
  
	;with cteAntiguedad(Anio, FechaIni) AS  
    (  
		SELECT cast(1.0 as float),@FechaAntiguedad  
		UNION ALL  
		SELECT Anio + 1.0,dateadd(year,1,FechaIni)  
		FROM cteAntiguedad WHERE Anio <= @AniosAntiguedad -- how many times to iterate  
    )  

	select *  
	INTO #tempCTE  
	from cteAntiguedad    

  
	SELECT ROW_NUMBER()Over(Order by  
                                    case when @orderByColumn = 'Anio'			and @orderDirection = 'asc'		then  Anio end ,
                                    case when @orderByColumn = 'Anio'			and @orderDirection = 'desc'		then Anio end desc                                     
        )  as [row],
		 cteAntiguedad.*  
		,dateadd(year,1, dateadd(day,-1,FechaIni)) as FechaFin  
		,IE.Fecha
		,1 as DiasUtilizados
		,case when 
			isnull(ie.Autorizado,0) = 0 
				then JSON_VALUE(@traduccionYESNO, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NO'))
				else JSON_VALUE(@traduccionYESNO, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'SI')) END as Autorizado
		, UsuarioAutoriza = upper( ua.Cuenta +' - '+ua.Nombre +' '+ua.Apellido)
		, ie.Comentario
		, CreadoPor =  upper(uc.Cuenta +' - '+uc.Nombre +' '+uc.Apellido)
		, JSON_VALUE(inc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
 	INTO #tempSetPagination  	
	FROM #tempCTE cteAntiguedad  
		left join (select *  
					from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad   
		inner join Asistencia.tblIncidenciaEmpleado IE
			on IE.IDIncidencia = 'V'
				and IE.Autorizado = 1
				and IE.IDEmpleado = @IDEmpleado
				and IE.Fecha Between cteAntiguedad.FechaIni and dateadd(year,1, dateadd(day,-1,cteAntiguedad.FechaIni))
        inner join Asistencia.tblCatIncidencias inc on inc.IDIncidencia = IE.IDIncidencia
		left join Seguridad.tblUsuarios ua
			on ie.AutorizadoPor = ua.IDUsuario
		left join Seguridad.tblUsuarios uc
			on ie.CreadoPorIDUsuario = uc.IDUsuario

  
	--select @IDEmpleado as IDEmpleado,Anio,Fecha,DiasUtilizados , Autorizado, UsuarioAutoriza, Comentario, CreadoPor, Incidencia
	--from #tempSetPagination  
	--order by Fecha desc
	
	    if exists(select top 1 * from @dtPagination)
        BEGIN
            exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
        end
    else 
        begin 
            select  * From #tempSetPagination order by row desc
        end
GO

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
  
CREATE proc [Asistencia].[spBuscarVacacionesTomadasPorAniosRefactor] --390,1
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
  
	SELECT ROW_NUMBER()Over(Order by  
                                    case when @orderByColumn = 'Anio'			and @orderDirection = 'asc'		then  Anio end ,
                                    case when @orderByColumn = 'Anio'			and @orderDirection = 'desc'		then Anio end desc                                     
        )  as [row], 
         [cteAntiguedad].[Anio],     
         [cteAntiguedad].[FechaInicio] as FechaIni,
         [cteAntiguedad].[FechaFin]
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
	FROM Asistencia.tblSaldoVacacionesEmpleado  cteAntiguedad  with (nolock) 
		left join (select *  
					from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad   
		inner join Asistencia.tblIncidenciaEmpleado IE with (nolock) 
			on IE.IDIncidenciaEmpleado = cteAntiguedad.IDIncidenciaEmpleado
                and IE.IDIncidencia in ('V' , 'VP')
				and IE.Autorizado = 1
				and IE.IDEmpleado = @IDEmpleado
				--and IE.Fecha Between cteAntiguedad.FechaIni and dateadd(year,1, dateadd(day,-1,cteAntiguedad.FechaIni))
        inner join Asistencia.tblCatIncidencias inc with (nolock)  on inc.IDIncidencia = IE.IDIncidencia
		left join Seguridad.tblUsuarios  ua with (nolock) 
			on ie.AutorizadoPor = ua.IDUsuario
		left join Seguridad.tblUsuarios uc with (nolock) 
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

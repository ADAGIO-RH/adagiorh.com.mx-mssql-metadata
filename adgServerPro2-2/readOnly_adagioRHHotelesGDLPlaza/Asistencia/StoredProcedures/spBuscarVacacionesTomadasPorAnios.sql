USE [readOnly_adagioRHHotelesGDLPlaza]
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
  
CREATE proc [Asistencia].[spBuscarVacacionesTomadasPorAnios] --390,1
(  
    @IDEmpleado int  
    ,@IDUsuario int  
) as  
  
	SET FMTONLY OFF;  
  
	declare   
		--@IDEmpleado int = 19959  
		 @FechaAntiguedad date  
		,@FechaIni date = getdate()  
		,@FechaFin date = getdate()  
		,@IDTipoPrestacion int  
		--,@ClaveEmpleado varchar(10) = '000914'  
		,@IDCliente int  
		,@AniosAntiguedad float = 0  
		,@VacacionesCaducanEn float = 0  
		,@MaxAnio int = 0  
	;  
  
	if object_id('tempdb..#tempDiasVacaciones') is not null drop table #tempDiasVacaciones;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  
  
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
   
 --select * from #tempCTE  cteAntiguedad  
 --   left join   
 --   (select *  
 --   from RH.tblCatTiposPrestacionesDetalle  
 --   where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad   
  
  
	SELECT cteAntiguedad.*  
		,dateadd(year,1, dateadd(day,-1,FechaIni)) as FechaFin  
		,IE.Fecha
		,1 as DiasUtilizados
		,case when isnull(ie.Autorizado,0) = 0 then 'NO' else 'SI' end as Autorizado
		, UsuarioAutoriza = upper( ua.Cuenta +' - '+ua.Nombre +' '+ua.Apellido)
		, ie.Comentario
		, CreadoPor =  upper(uc.Cuenta +' - '+uc.Nombre +' '+uc.Apellido)
		, Incidencia = 'VACACIONES'
 	INTO #tempDiasVacaciones  
		--,case when dateadd(year,@VacacionesCaducanEn,FechaFin) > cast(getdate() as date) then   as DiasVencidos  
	FROM #tempCTE cteAntiguedad  
		left join (select *  
					from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad   
		inner join Asistencia.tblIncidenciaEmpleado IE
			on IE.IDIncidencia = 'V'
				and IE.Autorizado = 1
				and IE.IDEmpleado = @IDEmpleado
				and IE.Fecha Between cteAntiguedad.FechaIni and dateadd(year,1, dateadd(day,-1,cteAntiguedad.FechaIni))
		left join Seguridad.tblUsuarios ua
			on ie.AutorizadoPor = ua.IDUsuario
		left join Seguridad.tblUsuarios uc
			on ie.CreadoPorIDUsuario = uc.IDUsuario
 -- print 'over'
	--update #tempDiasVacaciones  
 --   set DiasVencidos = case   
 --       when (DiasTomados > Dias) then 0   
 --       when DATEadd(day,@VacacionesCaducanEn,FechaFin) < getdate() then  Dias - DiasTomados else 0 end  
	--,DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  
  
 --   select @MaxAnio = max(Anio)  
 --   from #tempDiasVacaciones  
  
	select @IDEmpleado as IDEmpleado,Anio,Fecha,DiasUtilizados , Autorizado, UsuarioAutoriza, Comentario, CreadoPor, Incidencia
	from #tempDiasVacaciones  
	order by Fecha desc
  
    --update #tempDiasVacaciones  
    --set DiasDisponibles = (select sum(DiasDisponibles) from #tempDiasVacaciones)  
    --where Anio = @MaxAnio  
  
	--select 
	--	isnull(Anio,0) as Anio  
	--	,ISNULL(FechaIni, getdate()) as FechaIni  
	--	,ISNULL(FechaFin, getdate()) as FechaFin  
	--	,Dias  
	--	,DiasTomados  
	--	,DiasVencidos  
	--	,DiasDisponibles  
	--from #tempDiasVacaciones  
	--order by Anio desc
GO

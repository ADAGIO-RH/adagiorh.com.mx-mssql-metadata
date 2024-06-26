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
  
  select * from RH.tblEmpleadosMaster where claveEmpleado= 'adg0001'
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=390,@Proporcional=1,@IDUsuario=290
CREATE proc [Asistencia].[spBuscarSaldosVacacionesPorAnios]-- 390,0,1
(  
    @IDEmpleado int  
    ,@Proporcional bit = 0
    ,@IDUsuario int  
) as  
  
	SET FMTONLY OFF;  

	set @Proporcional = 0
  
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
		,@totalVacaciones int = 0
		,@counter int = 1
	;  

	set @Proporcional = 0
  
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
   select @totalVacaciones = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',@FechaAntiguedad,'9999-12-31')
  
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
  
	select @AniosAntiguedad  = case when @AniosAntiguedad < 1.0 then 1 else @AniosAntiguedad end

	if not exists (select top 1 1   
					 from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					 where IDTipoPrestacion = @IDTipoPrestacion 
						and Antiguedad = case when @AniosAntiguedad < 1 then 1 else cast(@AniosAntiguedad as int) end)  
	begin  
		exec app.spObtenerError  @IDUsuario= @IDUsuario,@CodigoError='0410002'  
		return  
	end;  
  
  -- select @AniosAntiguedad  ,cast(@AniosAntiguedad as int), ROUND(@AniosAntiguedad, 0)
  
	;with cteAntiguedad(Anio, FechaIni) AS  
    (  
		SELECT cast(1.0 as float),@FechaAntiguedad  
		UNION ALL  
		SELECT Anio + 1.0,dateadd(year,1,FechaIni)  
		FROM cteAntiguedad WHERE Anio <= @AniosAntiguedad-- how many times to iterate  
    )  

	select *  
	INTO #tempCTE  
	from cteAntiguedad  
	where Anio <= case when @Proporcional = 0 then  cast(@AniosAntiguedad as int) else ROUND(@AniosAntiguedad, 0) end
   
 --select * from #tempCTE  cteAntiguedad  
 --   left join   
 --   (select *  
 --   from RH.tblCatTiposPrestacionesDetalle  
 --   where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad   
  
  
	SELECT cteAntiguedad.*  
		,dateadd(year,1, dateadd(day,-1,FechaIni)) as FechaFin  
		,isnull(prestaciones.DiasVacaciones,0) as Dias  
		--,[Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',FechaIni,dateadd(year,1, dateadd(day,-1,FechaIni))) as DiasTomados       
		,0 as DiasTomados       
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
	INTO #tempDiasVacaciones  
		--,case when dateadd(year,@VacacionesCaducanEn,FechaFin) > cast(getdate() as date) then   as DiasVencidos  
	FROM #tempCTE cteAntiguedad  
		left join (select *  
					from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad  
					
	while(@counter <= (select max(Anio) from #tempDiasVacaciones))
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = case when @totalVacaciones <= Dias then @totalVacaciones
								   else Dias end
		where Anio = @counter

		set @totalVacaciones = @totalVacaciones - (select DiasTomados from #tempDiasVacaciones where Anio = @counter)

		set @counter = @counter + 1
	END					
	
	update #tempDiasVacaciones  
    set DiasVencidos = case   
			when (DiasTomados > Dias) then 0   
			when DATEadd(day,@VacacionesCaducanEn,FechaFin) < getdate() then  Dias - DiasTomados else 0 end  
		,DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  
  
 -- select * from #tempDiasVacaciones	
    select @MaxAnio = max(Anio)  
    from #tempDiasVacaciones  
  
  --select @MaxAnio

	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	if(@Proporcional = 1)
	BEGIN
		update v	
			set Dias = (DATEDIFF(day, FechaIni, getdate())/365.4)*Dias,
			 DiasDisponibles = ((DATEDIFF(day, FechaIni, getdate())/365.4)*Dias)-DiasTomados		
		from #tempDiasVacaciones v
		where Anio = @MaxAnio
	END
	ELSE
	BEGIN
		update v	
			set DiasDisponibles = Dias - DiasTomados
		from #tempDiasVacaciones v
		where Anio = @MaxAnio
	END

	--select *  
	--from #tempDiasVacaciones  
  
    --update #tempDiasVacaciones  
    --set DiasDisponibles = (select sum(DiasDisponibles) from #tempDiasVacaciones)  
    --where Anio = @MaxAnio  
  
	select 
		isnull(Anio,0) as Anio  
		,ISNULL(FechaIni, getdate()) as FechaIni  
		,ISNULL(FechaFin, getdate()) as FechaFin  
		,Dias  
		,DiasTomados  
		,DiasVencidos  
		,cast(DiasDisponibles as decimal(18,2)) as  DiasDisponibles 
	from #tempDiasVacaciones  
	order by Anio desc
GO

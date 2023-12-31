USE [p_adagioRHCSMPresupuesto]
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
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-11-30				Aneudy Abreu	Se agrega validación para cuando el colaborador tiene más
										de una Prestación
***************************************************************************************************/  
  --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=390,@Proporcional=1,@IDUsuario=290
create proc [Asistencia].[spCustomBuscarSaldosVacacionesPorAnios_CSM_2]-- 390,0,1
(  
    @IDEmpleado int 
	,@Proporcional bit 
    --,@Proporcional bit = 0
	,@FechaBaja date = null
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
		,@totalVacaciones int = 0
		,@counter int = 1
	;  

	--set @Proporcional = 1
	set @FechaBaja = isnull(@FechaBaja, getdate())
  
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
  
	;with cteAntiguedad(Anio, FechaIni, IDTipoPrestacion, TipoPrestacion) AS  
    (  
		SELECT cast(1.0 as float), @FechaAntiguedad, 0, cast('' as varchar(50))  
		UNION ALL  
		SELECT Anio + 1.0, dateadd(year,1,FechaIni), 0, cast('' as varchar(50))  
		FROM cteAntiguedad WHERE Anio <= @AniosAntiguedad-- how many times to iterate  
    )  

    select *, dateadd(year,1, dateadd(day,-1,FechaIni)) as FechaFin
	INTO #tempCTE  
	from cteAntiguedad  
	where Anio <= case when @Proporcional = 0 then  cast(@AniosAntiguedad as int) else CEILING(@AniosAntiguedad) end
   

  update anios
		set
			anios.IDTipoPrestacion = pe.IDTipoPrestacion,
			anios.TipoPrestacion = ctp.Descripcion
	from #tempCTE anios
		join RH.tblPrestacionesEmpleado pe on anios.FechaFin between pe.FechaIni and pe.FechaFin
		join RH.tblCatTiposPrestaciones ctp on ctp.IDTipoPrestacion = pe.IDTipoPrestacion
	where pe.IDEmpleado = @IDEmpleado
  
	SELECT cteAntiguedad.*  
		,isnull(ctpd.DiasVacaciones,0) as Dias
		,0 as DiasTomados       
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,cast(null as date) as FechaIniDisponible
		,cast(null as date)  as FechaFinDisponible
	INTO #tempDiasVacaciones  
	FROM #tempCTE cteAntiguedad  
		left join RH.tblCatTiposPrestacionesDetalle ctpd with (nolock)   
			on ctpd.IDTipoPrestacion = cteAntiguedad.IDTipoPrestacion and cteAntiguedad.Anio = ctpd.Antiguedad 

   		

	select @MaxAnio = max(Anio)  
    from #tempDiasVacaciones 

-----------------------------------------------------------------------------------------------------------
/* Se aplica dos veces para corregir algunos que en primer update tienen fechaFinDisponible desactualizada*/

	update t set FechaIniDisponible =  CASE WHEN Anio = 1 then DATEADD(YEAR,1,@FechaAntiguedad) else (select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1)) end
    --update t set FechaIniDisponible =  CASE WHEN Anio = 1 then (CASE WHEN @Proporcional=1 then @FechaAntiguedad else DATEADD(YEAR,1,@FechaAntiguedad) end) else (select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1)) end
        ,FechaFinDisponible = Case when Anio = @MaxAnio then '9999-12-31' 
								   --else cast( dateadd(day, cast(@VacacionesCaducanEn as int), (CASE WHEN @Proporcional=1 then FechaFin else DATEADD(YEAR,1,FechaFin) end))  as date)
                                   else cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)
							   end
	from #tempDiasVacaciones t



    update t set FechaIniDisponible =  CASE WHEN Anio = 1 then DATEADD(YEAR,1,@FechaAntiguedad) else (select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1)) end
	--update t set FechaIniDisponible =  CASE WHEN Anio = 1 then (CASE WHEN @Proporcional=1 then @FechaAntiguedad else DATEADD(YEAR,1,@FechaAntiguedad) end) else (select FechaFinDisponible from #tempDiasVacaciones where anio =(t.anio - 1)) end
		,FechaFinDisponible = Case when Anio = @MaxAnio then '9999-12-31' 
								   --else cast( dateadd(day, cast(@VacacionesCaducanEn as int), (CASE WHEN @Proporcional=1 then FechaFin else DATEADD(YEAR,1,FechaFin) end))  as date)
                                   else cast( dateadd(day, cast(@VacacionesCaducanEn as int), FechaFin)  as date)
							   end
	from #tempDiasVacaciones t

     ---SELECT * FROM #tempDiasVacaciones RETURN

-----------------------


					
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
  
  --select * from #tempDiasVacaciones	

    select @MaxAnio = max(Anio)  --//////
    from #tempDiasVacaciones  
  
  --select @totalVacaciones

	if(@totalVacaciones > 0)
	BEGIN
		update #tempDiasVacaciones
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	if(@Proporcional = 1)
	BEGIN
		update v	
			set-- Dias = (DATEDIFF(day, FechaIni, @FechaBaja)/365.4)*Dias,
			 DiasDisponibles = ( ( ( DATEDIFF( day, FechaIni, @FechaBaja ) + 1 ) / 365.4 ) * Dias )		
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

--select * from #tempDiasVacaciones	--///////
--return;

	--select *  
	--from #tempDiasVacaciones  
  
    --update #tempDiasVacaciones  
    --set DiasDisponibles = (select sum(DiasDisponibles) from #tempDiasVacaciones)  
    --where Anio = @MaxAnio  
  
	select 
		*
	from #tempDiasVacaciones  
	order by Anio desc
GO

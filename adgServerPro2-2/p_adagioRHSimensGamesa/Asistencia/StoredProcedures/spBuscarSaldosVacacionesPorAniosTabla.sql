USE [p_adagioRHSimensGamesa]
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
2022-01-01				Aneudy Abreu	Se agregó validación del historial de prestaciones
2022-01-01				Julio Castillo	Se agregó el parámetro de FechaBaja
***************************************************************************************************/  
  --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=1279,@Proporcional=0,@IDUsuario=1
CREATE proc [Asistencia].[spBuscarSaldosVacacionesPorAniosTabla]-- 390,0,1
(  
		
		@Proporcional bit
	  --,@Proporcional	bit = 0
		,@FechaBaja date = null
		,@IDUsuario	int
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
		,@totalVacaciones int = 0
		,@counter int = 1

		,@IDEmpleado int = 0			  
	    ,@orderByColumn	varchar(50) = 'Anio'
	    ,@orderDirection varchar(4) = 'asc' 
	;  


	set @FechaBaja = isnull(@FechaBaja, getdate())
  
	  IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL
    BEGIN
        DROP TABLE #tempSetPagination
    END
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
  
	select @AniosAntiguedad  = case when @AniosAntiguedad < 1.0 /*and @Proporcional = 1*/ then 1 else @AniosAntiguedad end

	if not exists (select top 1 1   
					 from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					 where IDTipoPrestacion = @IDTipoPrestacion 
						and Antiguedad = case when @AniosAntiguedad < 1 then 1 else cast(@AniosAntiguedad as int) end)  
	begin  
		exec app.spObtenerError  @IDUsuario= @IDUsuario,@CodigoError='0410002'  
		return  
	end;  
  

	;with cteAntiguedad(Anio, FechaIni) AS
	(
		SELECT cast(1.0 as float),@FechaAntiguedad
		UNION ALL
		SELECT Anio + 1.0,dateadd(year,1,FechaIni)
		FROM cteAntiguedad WHERE Anio < @AniosAntiguedad-- how many times to iterate
	)
	

	 select * 
	 INTO #tempCTE
	 from cteAntiguedad
	 where Anio <= case when @Proporcional = 0 then  cast(@AniosAntiguedad as int) else CEILING(@AniosAntiguedad) end
   


	SELECT 	   ROW_NUMBER()Over(Order by  
                                    case when @orderByColumn = 'Anio'			and @orderDirection = 'asc'		then  Anio end ,
                                    case when @orderByColumn = 'Anio'			and @orderDirection = 'desc'		then Anio end desc                                     
        )  as [row],
	cteAntiguedad.*  
		,dateadd(year,1, dateadd(day,-1,FechaIni)) as FechaFin  
		,isnull(prestaciones.DiasVacaciones,0) as Dias
		--,isnull(ctpd.DiasVacaciones,0) as Dias  
		,0 as DiasTomados       
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
	INTO #tempSetPagination  
	FROM #tempCTE cteAntiguedad  
		left join (select *  
					from RH.tblCatTiposPrestacionesDetalle with (nolock)   
					where IDTipoPrestacion = @IDTipoPrestacion) as prestaciones on cteAntiguedad.Anio = prestaciones.Antiguedad  	
		

	while(@counter <= (select max(Anio) from #tempSetPagination))
	BEGIN
		update #tempSetPagination
			set DiasTomados = case when @totalVacaciones <= Dias then @totalVacaciones
								   else Dias end
		where Anio = @counter

		set @totalVacaciones = @totalVacaciones - (select DiasTomados from #tempSetPagination where Anio = @counter)

		set @counter = @counter + 1
	END					
	
	update #tempSetPagination  
    set DiasVencidos = case   
			when (DiasTomados > Dias) then 0   
			when DATEadd(day,@VacacionesCaducanEn,FechaFin) < getdate() then  Dias - DiasTomados else 0 end  
		,DiasDisponibles = case when DATEadd(day,@VacacionesCaducanEn,FechaFin) > getdate() then Dias - DiasTomados else 0 end  
  
    select @MaxAnio = max(Anio)  
    from #tempSetPagination  

	if(@totalVacaciones > 0)
	BEGIN
		update #tempSetPagination
			set DiasTomados = DiasTomados + @totalVacaciones
		where Anio = @MaxAnio
	END

	if(@Proporcional = 1)
	BEGIN
		update v	
			set Dias = (DATEDIFF(day,FechaIni,@FechaBaja)/365.4)*Dias, /*FechaIni, getdate())/365.4)*Dias,*/
				DiasDisponibles = (((DATEDIFF(day, FechaIni, @FechaBaja)+1)/365.4)*Dias)-DiasTomados --getdate())/365.4)*Dias)-DiasTomados		
		from #tempSetPagination v
		where Anio = @MaxAnio
	END
	ELSE
	BEGIN
		update v	
			set DiasDisponibles = Dias - DiasTomados
		from #tempSetPagination v
		where Anio = @MaxAnio
	END	

	    if exists(select top 1 * from @dtPagination)
        BEGIN
            exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
        end
    else 
        begin 
            select  * From #tempSetPagination order by row desc
        end
	/*if object_id('tempdb..#tempSetPagination') is not null drop table #tempSetPagination;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;*/
GO

USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Dashboard].[spBuscarHistorialVigentesNoVigentes](
	@FechaIni date = null,
	@Fechafin date = null 
)as 
	DECLARE
		@TotalVigentes int = 0,
		@TotalNoVigentes int = 0;

    select 
        @FechaIni = isnull(@FechaIni,getdate()-15)
        ,@Fechafin = isnull(@Fechafin,getdate())

	declare @fechasVigencias as table (
		Fecha date, 
		Vigentes int, 
		NoVigentes int,
		Total as isnull(Vigentes, 0) + isnull(NoVigentes, 0)
	)

    while (@FechaIni <= @FechaFin)
    begin       
        -- Obtener empleados vigentes
        SELECT @TotalVigentes = count(E.IDEmpleado)
        FROM [RH].[tblEmpleados] E WITH(NOLOCK)    
        ,(select IDEmpleado, FechaAlta, FechaBaja,
                case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
                from (select distinct tm.IDEmpleado,
                    case when(IDEmpleado is not null) then (select top 1 Fecha 
                                                    from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)
                                                    join [IMSS].[tblCatTipoMovimientos]      c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento
                                                    where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'  
                                                    Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,
                    case when (IDEmpleado is not null) then (select top 1 Fecha 
                                                    from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)
                                                    join [IMSS].[tblCatTipoMovimientos]      c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento
                                                    where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'  
                                                    and mBaja.Fecha <= @FechaIni 
                                                    order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,
                    case when (IDEmpleado is not null) then (select top 1 Fecha 
                                                    from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)
                                                    join [IMSS].[tblCatTipoMovimientos]      c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento
                                                    where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'  
                                                    and mReingreso.Fecha <= @FechaIni 
                                                    order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso                                                                    
                    from [IMSS].[tblMovAfiliatorios]  tm ) mm ) M            
        WHERE E.IDEmpleado = m.IDEmpleado and ( (M.FechaAlta<=@FechaIni and (M.FechaBaja>=@FechaIni or M.FechaBaja is null)) or (M.FechaReingreso<=@FechaIni));

        -- Obtener empleados no vigentes (dados de baja)
        SELECT @TotalNoVigentes = count(E.IDEmpleado)
        FROM [RH].[tblEmpleados] E WITH(NOLOCK)    
        ,(select IDEmpleado, FechaAlta, FechaBaja,
                case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso
                from (select distinct tm.IDEmpleado,
                    case when(IDEmpleado is not null) then (select top 1 Fecha 
                                                    from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)
                                                    join [IMSS].[tblCatTipoMovimientos]      c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento
                                                    where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'  
                                                    Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,
                    case when (IDEmpleado is not null) then (select top 1 Fecha 
                                                    from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)
                                                    join [IMSS].[tblCatTipoMovimientos]      c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento
                                                    where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'  
                                                    and mBaja.Fecha <= @FechaIni 
                                                    order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,
                    case when (IDEmpleado is not null) then (select top 1 Fecha 
                                                    from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)
                                                    join [IMSS].[tblCatTipoMovimientos]      c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento
                                                    where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'  
                                                    and mReingreso.Fecha <= @FechaIni 
                                                    order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso                                                                    
                    from [IMSS].[tblMovAfiliatorios]  tm ) mm ) M            
        WHERE E.IDEmpleado = m.IDEmpleado 
        AND M.FechaBaja <= @FechaIni 
        AND (M.FechaReingreso IS NULL OR M.FechaReingreso > @FechaIni);

        print cast(@FechaIni as varchar)+' - Vigentes: ' + cast(@TotalVigentes as varchar) + ' - No Vigentes: ' + cast(@TotalNoVigentes as varchar)           
        
		insert @fechasVigencias
		select  @FechaIni as Fecha, @TotalVigentes as Vigente, @TotalNoVigentes as NoVigentes
       
        set @FechaIni = DATEADD(day,1,@FechaIni);
    end;

	select * 
	from @fechasVigencias
GO

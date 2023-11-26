USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCerrarPeriodoNomina]  --366,1
(
	@IDPeriodo int ,
	@Value bit,
	@IDUsuario int 
)
AS
BEGIN
	declare 
		@OldJSON varchar(Max) = '',
		@NewJSON varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spCerrarPeriodoNomina]',
		@Tabla		varchar(max) = '[Nomina].[tblCatPeriodos]',
		@Accion		varchar(20)	= case when @Value = 1 then 'CIERRE DE PERIODO' else 'ABRIENDO PERIODO' end,
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max),
		@IdsPedidos varchar(max)
	;

	declare 
		@IDTipoNomina int,
		@FechaInicioPago date,
		@FechaFinPago date,
		@empleados [RH].[dtEmpleados]
		,@finiquito bit
	;

	if object_id('tempdb..#tempEmpleadosPeriodo') is not null drop table #tempEmpleadosPeriodo;
	if object_id('tempdb..#TempHistorial') is not null drop table #TempHistorial;
	if object_id('tempdb..#TempEmpleadosFiniquito') is not null drop table #TempEmpleadosFiniquito;
	if object_id('tempdb..#tempEmpleadosPeriodoAsimilado') is not null drop table #tempEmpleadosPeriodoAsimilado;
	
	select @OldJSON = a.JSON 
	from Nomina.tblCatPeriodos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDPeriodo, b.ClavePeriodo, b.Descripcion, b.Cerrado For XML Raw)) ) a
	WHERE  IDPeriodo = @IDPeriodo

	Update Nomina.tblCatPeriodos
		set Cerrado = @Value
	Where IDPeriodo = @IDPeriodo

	select @NewJSON = a.JSON
	from Nomina.tblCatPeriodos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.IDPeriodo, b.ClavePeriodo, b.Descripcion, b.Cerrado For XML Raw)) ) a
	WHERE  IDPeriodo = @IDPeriodo

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
		,@Mensaje		= @Mensaje
		,@InformacionExtra = @InformacionExtra

	select	@IdsPedidos = STUFF(
		(   SELECT ','+IdsPeriodos
			FROM Comedor.tblPeriodosDescontadosEmpleados with (nolock)
			where IDPeriodo = @IDPeriodo	
			FOR xml path('')
		)
		, 1
		, 1
		, ''
	)

	IF(@Value = 1)
	BEGIN
		Select @IDTipoNomina = IDTipoNomina,
			   @FechaInicioPago = FechaFinIncidencia,
			   @FechaFinPago = FechaFinPago,
			   @finiquito = isnull(Finiquito,0)
		From Nomina.tblCatPeriodos with (nolock)
		where IDPeriodo = @IDPeriodo

		IF(@finiquito = 0)
		BEGIN
			insert into @empleados
			exec RH.spBuscarEmpleados @IDTipoNomina = @IDTipoNomina,@FechaIni=@FechaInicioPago,@Fechafin=@FechaFinPago , @IDUsuario= @IDUsuario
		END
		ELSE
		BEGIN
			--insert into @empleados
			--exec RH.spBuscarEmpleados @IDTipoNomina = @IDTipoNomina, @IDUsuario= @IDUsuario

			Declare @IDEmpleadoFiniquitoProceso int = 0,
					@ClaveEmpleado varchar(20),
					@fechaBaja Date,
					@FechaAntiguedad Date

			select CF.IDEmpleado
				, e.ClaveEmpleado
				, cf.FechaBaja
				, isnull(cf.FechaAntiguedad,dateadd(day,-1,cf.FechaBaja)) FechaAntiguedad
			into #TempEmpleadosFiniquito
			from Nomina.tblControlFiniquitos cf with(nolock)
				inner join RH.tblEmpleados e with(nolock)
					on cf.IDEmpleado = e.IDEmpleado
			where cf.IDPeriodo = @IDPeriodo
				and cf.IDEStatusFiniquito = 2
		
			select @IDEmpleadoFiniquitoProceso = min(IDEmpleado) 
			from #TempEmpleadosFiniquito
			where IDEmpleado > @IDEmpleadoFiniquitoProceso

			select @ClaveEmpleado = ClaveEmpleado,
				  @fechaBaja = FechaBaja,
				  @FechaAntiguedad = FechaAntiguedad
			from #TempEmpleadosFiniquito
			where IDEmpleado = @IDEmpleadoFiniquitoProceso

			WHILE (@IDEmpleadoFiniquitoProceso <= (Select MAX(IDEmpleado) from #TempEmpleadosFiniquito))
			BEGIN
				select @ClaveEmpleado = ClaveEmpleado,
					  @fechaBaja = FechaBaja,
					  @FechaAntiguedad = FechaAntiguedad
				from #TempEmpleadosFiniquito
				where IDEmpleado = @IDEmpleadoFiniquitoProceso

				insert into @empleados
				exec RH.spBuscarEmpleados @IDTipoNomina = @IDTipoNomina
					,@FechaIni=@FechaAntiguedad
					,@Fechafin=@fechaBaja 
					,@EmpleadoIni = @ClaveEmpleado
					,@EmpleadoFin = @ClaveEmpleado
					,@IDUsuario= @IDUsuario

					select @IDEmpleadoFiniquitoProceso = min(IDEmpleado) 
					from #TempEmpleadosFiniquito
					where IDEmpleado > @IDEmpleadoFiniquitoProceso
			END

				
		END

		--select * from @empleados

		Select distinct dp.IDPeriodo, dp.IDEmpleado 
		into #tempEmpleadosPeriodo
		from Nomina.tblDetallePeriodo dp with (nolock)
			join Nomina.tblCatConceptos c on c.IDConcepto = dp.IDConcepto and c.Codigo = '550'
		Where dp.IDPeriodo = @IDPeriodo and isnull(dp.ImporteAcumuladoTotales, 0) <> 0

		Select distinct dp.IDPeriodo, dp.IDEmpleado 
		into #tempEmpleadosPeriodoAsimilado
		from Nomina.tblDetallePeriodo dp with (nolock)
			join Nomina.tblCatConceptos c on c.IDConcepto = dp.IDConcepto and c.Codigo = 'A550'
		Where dp.IDPeriodo = @IDPeriodo and isnull(dp.ImporteAcumuladoTotales, 0) <> 0

		--select * from #tempEmpleadosPeriodo

		Select EP.IDPeriodo,
			   E.IDEmpleado,
			   E.IDCentroCosto,
			   E.IDDepartamento,
			   E.IDSucursal,
			   E.IDPuesto,
			   E.IDRegPatronal,
			   E.IDCliente,
			   E.IDEmpresa,
			   E.IDArea,
			   E.IDDivision,
			   E.IDClasificacionCorporativa,
			   E.IDRegion,
			   E.IDRazonSocial,
			   0 as Asimilado
		Into #TempHistorial 
		From @empleados e
			Inner join #tempEmpleadosPeriodo EP
				on e.IDEmpleado = EP.IDEmpleado

		insert into #TempHistorial
		Select EP.IDPeriodo,
			   E.IDEmpleado,
			   E.IDCentroCosto,
			   E.IDDepartamento,
			   E.IDSucursal,
			   E.IDPuesto,
			   E.IDRegPatronal,
			   E.IDCliente,
			   E.IDEmpresa,
			   E.IDArea,
			   E.IDDivision,
			   E.IDClasificacionCorporativa,
			   E.IDRegion,
			   E.IDRazonSocial,
			   1 as Asimilado
		From @empleados e
			Inner join #tempEmpleadosPeriodoAsimilado EP
				on e.IDEmpleado = EP.IDEmpleado
		
		--select * from #TempHistorial

		MERGE Nomina.tblHistorialesEmpleadosPeriodos AS TARGET
			  USING #TempHistorial AS SOURCE
				 ON (TARGET.IDEmpleado = SOURCE.IDEmpleado 
					and TARGET.IDPeriodo = SOURCE.IDPeriodo
					and TARGET.Asimilado = SOURCE.Asimilado
					)
		   WHEN MATCHED  Then
			  update
				 Set 				
					 TARGET.IDCentroCosto	 = case when SOURCE.IDCentroCosto = 0 then null else SOURCE.IDCentroCosto end
					,TARGET.IDDepartamento   = case when SOURCE.IDDepartamento = 0 then null else SOURCE.IDDepartamento end
					,TARGET.IDSucursal		 = case when SOURCE.IDSucursal = 0 then null else SOURCE.IDSucursal end
					,TARGET.IDPuesto		 = case when SOURCE.IDPuesto = 0 then null else SOURCE.IDPuesto end
					,TARGET.IDRegPatronal    = case when SOURCE.IDRegPatronal = 0 then null else SOURCE.IDRegPatronal end
					,TARGET.IDCliente		 = case when SOURCE.IDCliente = 0 then null else SOURCE.IDCliente end
					,TARGET.IDEmpresa		 = case when SOURCE.IDEmpresa = 0 then null else SOURCE.IDEmpresa end
					,TARGET.IDArea			 = case when SOURCE.IDArea = 0 then null else SOURCE.IDArea end
					,TARGET.IDDivision		 = case when SOURCE.IDDivision = 0 then null else SOURCE.IDDivision end
					,TARGET.IDClasificacionCorporativa  = case when SOURCE.IDClasificacionCorporativa = 0 then null else SOURCE.IDClasificacionCorporativa end
					,TARGET.IDRegion					= case when SOURCE.IDRegion = 0 then null else SOURCE.IDRegion end
					,TARGET.IDRazonSocial				= case when SOURCE.IDRazonSocial = 0 then null else SOURCE.IDRazonSocial end
					,TARGET.Asimilado				= case when SOURCE.Asimilado = 0 then null else SOURCE.Asimilado end
					
				 WHEN NOT MATCHED BY TARGET THEN 
					INSERT(IDEmpleado,IDPeriodo,IDCentroCosto,IDDepartamento,IDSucursal,IDPuesto,IDRegPatronal,IDCliente,IDEmpresa,IDArea,IDDivision,IDClasificacionCorporativa,IDRegion,IDRazonSocial, Asimilado)
					VALUES(SOURCE.IDEmpleado
						  ,SOURCE.IDPeriodo
						  ,case when SOURCE.IDCentroCosto = 0 then null else SOURCE.IDCentroCosto end
						  ,case when SOURCE.IDDepartamento = 0 then null else SOURCE.IDDepartamento end
						  ,case when SOURCE.IDSucursal = 0 then null else SOURCE.IDSucursal end
						  ,case when SOURCE.IDPuesto = 0 then null else SOURCE.IDPuesto end
						  ,case when SOURCE.IDRegPatronal = 0 then null else SOURCE.IDRegPatronal end
						  ,case when SOURCE.IDCliente = 0 then null else SOURCE.IDCliente end
						  ,case when SOURCE.IDEmpresa = 0 then null else SOURCE.IDEmpresa end
						  ,case when SOURCE.IDArea = 0 then null else SOURCE.IDArea end
						  ,case when SOURCE.IDDivision = 0 then null else SOURCE.IDDivision end
						  ,case when SOURCE.IDClasificacionCorporativa = 0 then null else SOURCE.IDClasificacionCorporativa end
						  ,case when SOURCE.IDRegion = 0 then null else SOURCE.IDRegion end
						  ,case when SOURCE.IDRazonSocial = 0 then null else SOURCE.IDRazonSocial end
						  ,case when SOURCE.Asimilado = 0 then null else SOURCE.Asimilado end)
					
				WHEN NOT MATCHED BY SOURCE 
					and Target.IDPeriodo = @IDPeriodo 
					and TARGET.IDHistorialEmpleadoPeriodo not in (SELECT IDHistorialEmpleadoPeriodo FROM Facturacion.TblTimbrado with (nolock)) 
				THEN 
				DELETE;

		UPDATE p
			set p.IDEstatusPrestamo = (Select TOP 1 IDEstatusPrestamo from Nomina.tblCatEstatusPrestamo where Descripcion = 'ACTIVO')
		FROM Nomina.tblDetallePeriodo dp with (nolock)
			inner join Nomina.tblCatConceptos C with (nolock)
				on dp.IDConcepto = c.IDConcepto and c.Codigo in ('144','167')
			Inner join Nomina.tblPrestamos p with (nolock)
				on p.IDPrestamo = dp.IDReferencia
		where dp.IDPeriodo = @IDPeriodo

		if object_id('tempdb..#tempPrestamosSaldados') is not null drop table #tempPrestamosSaldados;

		select   
			p.*,  
			P.MontoPrestamo - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		INTO #tempPrestamosSaldados
		from [Nomina].[tblPrestamos] p with (nolock)   
			inner join [Nomina].[tblCatTiposPrestamo] TP with (nolock) on p.IDTipoPrestamo = TP.IDTipoPrestamo
			inner join [Nomina].[tblPrestamosFondoAhorro] pfa with (nolock) on p.IDPrestamo = pfa.IDPrestamo --and pfa.IDEmpleado = @IDEmpleado   
			inner join [Nomina].[tblCatEstatusPrestamo] EP with (nolock) on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
			inner join [RH].[tblEmpleados] e with (nolock) on P.IDEmpleado = e.IDEmpleado    
		where p.IDEstatusPrestamo in (1,2)

		delete from #tempPrestamosSaldados where Balance > 0

		update p 
			set p.IDEstatusPrestamo = 4
		from Nomina.tblPrestamos p
			join #tempPrestamosSaldados tp on p.IDPrestamo = tp.IDPrestamo

		update p
			set 
				p.DescontadaDeNomina = 1,
				p.FechaHoraDescuento = getdate(),
				p.IDPeriodo = @IDPeriodo
		from Comedor.tblPedidos p
			join (select cast(item as int) IDPedido from App.Split(@IdsPedidos,',')) idsP on idsP.IDPedido = p.IDPedido
	END ELSE
	BEGIN
		update p
			set 
				p.DescontadaDeNomina = 0,
				p.FechaHoraDescuento = NULL,
				p.IDPeriodo = NULL
		from Comedor.tblPedidos p
			join (select cast(item as int) IDPedido from App.Split(@IdsPedidos,',')) idsP on idsP.IDPedido = p.IDPedido
	END
END
GO

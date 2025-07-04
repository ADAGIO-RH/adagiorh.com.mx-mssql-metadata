USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spGenerarFolioCFDIFiniquito](
	@IDFiniquito int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@FechaInicioPago date,
		@FechaFinPago date,
		@empleados [RH].[dtEmpleados],
		@finiquito bit,
		@IDPeriodo int,

		@IDEmpleadoFiniquitoProceso int = 0,
		@ClaveEmpleado varchar(20),
		@fechaBaja Date,
		@FechaAntiguedad Date,

		@ID_ESTATUS_FINIQUITO_APLICAR INT = 2,
		@ID_TIPO_CONCEPTO_CONCEPTOS_TOTALES INT = 6,
		@ID_TIPO_CONCEPTO_CONCEPTOS_TOTALES_ASIMILADOS INT = 12,
		@Asimilado bit = 0
	;

	if object_id('tempdb..#tempEmpleadosPeriodo') is not null drop table #tempEmpleadosPeriodo;
	if object_id('tempdb..#TempHistorial') is not null drop table #TempHistorial;
	if object_id('tempdb..#TempEmpleadosFiniquito') is not null drop table #TempEmpleadosFiniquito;
	if object_id('tempdb..#tempEmpleadosPeriodoAsimilado') is not null drop table #tempEmpleadosPeriodoAsimilado;
	

			select CF.IDFiniquito
				,CF.IDEmpleado
				, e.ClaveEmpleado
				, cf.FechaBaja
				, isnull(cf.FechaAntiguedad,dateadd(day,-1,cf.FechaBaja)) FechaAntiguedad
				,cf.IDPeriodo
			into #TempEmpleadosFiniquito
			from Nomina.tblControlFiniquitos cf with(nolock)
				inner join RH.tblEmpleados e with(nolock)
					on cf.IDEmpleado = e.IDEmpleado
			where cf.IDFiniquito = @IDFiniquito
				and cf.IDEstatusFiniquito = @ID_ESTATUS_FINIQUITO_APLICAR
		
	

			select @ClaveEmpleado = ClaveEmpleado,
				  @fechaBaja = FechaBaja,
				  @FechaAntiguedad = FechaAntiguedad,
				  @IDPeriodo = IDPeriodo
			from #TempEmpleadosFiniquito
			where IDFiniquito = @IDFiniquito

			insert into @empleados
			exec RH.spBuscarEmpleados                
					@FechaIni=@FechaAntiguedad
				,@Fechafin=@fechaBaja 
				,@EmpleadoIni = @ClaveEmpleado
				,@EmpleadoFin = @ClaveEmpleado
				,@IDUsuario= @IDUsuario

		Select distinct dp.IDPeriodo, dp.IDEmpleado 
		into #tempEmpleadosPeriodo
		from Nomina.tblDetallePeriodo dp with (nolock)
			join Nomina.tblCatConceptos c on c.IDConcepto = dp.IDConcepto 
				and c.Codigo like '%550%' -- TOTAL PERCEPCIONES
				and c.IDTipoConcepto = @ID_TIPO_CONCEPTO_CONCEPTOS_TOTALES
		Where dp.IDPeriodo = @IDPeriodo and isnull(dp.ImporteAcumuladoTotales, 0) <> 0

		--select * from #tempEmpleadosPeriodo

		Select distinct dp.IDPeriodo, dp.IDEmpleado 
		into #tempEmpleadosPeriodoAsimilado
		from Nomina.tblDetallePeriodo dp with (nolock)
			join Nomina.tblCatConceptos c on c.IDConcepto = dp.IDConcepto 
				and c.Codigo = 'A550' -- TOTAL PERCEPCIONES ASIMILADOS
				and c.IDTipoConcepto = @ID_TIPO_CONCEPTO_CONCEPTOS_TOTALES_ASIMILADOS
		Where dp.IDPeriodo = @IDPeriodo and isnull(dp.ImporteAcumuladoTotales, 0) <> 0


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
		WHERE ISNULL(@Asimilado,0) = 0
		--select * from @empleados


		--select * from #TempHistorial

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
		WHERE ISNULL(@Asimilado,0) = 1
		
		--select * from #TempHistorial

		MERGE Nomina.tblHistorialesEmpleadosPeriodos AS TARGET
			  USING #TempHistorial AS SOURCE
				 ON (TARGET.IDEmpleado = SOURCE.IDEmpleado 
					and TARGET.IDPeriodo = SOURCE.IDPeriodo
					--and TARGET.Asimilado = SOURCE.Asimilado
                    and ISNULL(TARGET.Asimilado,0) = SOURCE.Asimilado
					)
		   WHEN MATCHED  Then
			  update
				 Set 				
					 TARGET.IDCentroCosto	 = case when SOURCE.IDCentroCosto	= 0 then null else SOURCE.IDCentroCosto end
					,TARGET.IDDepartamento   = case when SOURCE.IDDepartamento	= 0 then null else SOURCE.IDDepartamento end
					,TARGET.IDSucursal		 = case when SOURCE.IDSucursal		= 0 then null else SOURCE.IDSucursal end
					,TARGET.IDPuesto		 = case when SOURCE.IDPuesto		= 0 then null else SOURCE.IDPuesto end
					,TARGET.IDRegPatronal    = case when SOURCE.IDRegPatronal	= 0 then null else SOURCE.IDRegPatronal end
					,TARGET.IDCliente		 = case when SOURCE.IDCliente	= 0 then null else SOURCE.IDCliente end
					,TARGET.IDEmpresa		 = case when SOURCE.IDEmpresa	= 0 then null else SOURCE.IDEmpresa end
					,TARGET.IDArea			 = case when SOURCE.IDArea		= 0 then null else SOURCE.IDArea end
					,TARGET.IDDivision		 = case when SOURCE.IDDivision	= 0 then null else SOURCE.IDDivision end
					,TARGET.IDClasificacionCorporativa  = case when SOURCE.IDClasificacionCorporativa = 0 then null else SOURCE.IDClasificacionCorporativa end
					,TARGET.IDRegion					= case when SOURCE.IDRegion			= 0 then null else SOURCE.IDRegion end
					,TARGET.IDRazonSocial				= case when SOURCE.IDRazonSocial	= 0 then null else SOURCE.IDRazonSocial end
					,TARGET.Asimilado				= case when SOURCE.Asimilado			= 0 then null else SOURCE.Asimilado end
					
				 WHEN NOT MATCHED BY TARGET THEN 
					INSERT(IDEmpleado,IDPeriodo,IDCentroCosto,IDDepartamento,IDSucursal,IDPuesto,IDRegPatronal,IDCliente,IDEmpresa,IDArea,IDDivision,IDClasificacionCorporativa,IDRegion,IDRazonSocial, Asimilado)
					VALUES(SOURCE.IDEmpleado
						  ,SOURCE.IDPeriodo
						  ,case when SOURCE.IDCentroCosto	= 0 then null else SOURCE.IDCentroCosto end
						  ,case when SOURCE.IDDepartamento	= 0 then null else SOURCE.IDDepartamento end
						  ,case when SOURCE.IDSucursal		= 0 then null else SOURCE.IDSucursal end
						  ,case when SOURCE.IDPuesto		= 0 then null else SOURCE.IDPuesto end
						  ,case when SOURCE.IDRegPatronal	= 0 then null else SOURCE.IDRegPatronal end
						  ,case when SOURCE.IDCliente	= 0 then null else SOURCE.IDCliente end
						  ,case when SOURCE.IDEmpresa	= 0 then null else SOURCE.IDEmpresa end
						  ,case when SOURCE.IDArea		= 0 then null else SOURCE.IDArea end
						  ,case when SOURCE.IDDivision	= 0 then null else SOURCE.IDDivision end
						  ,case when SOURCE.IDClasificacionCorporativa = 0 then null else SOURCE.IDClasificacionCorporativa end
						  ,case when SOURCE.IDRegion		= 0 then null else SOURCE.IDRegion end
						  ,case when SOURCE.IDRazonSocial	= 0 then null else SOURCE.IDRazonSocial end
						  ,case when SOURCE.Asimilado		= 0 then null else SOURCE.Asimilado end)
					
				WHEN NOT MATCHED BY SOURCE 
					and Target.IDPeriodo = @IDPeriodo 
					and TARGET.IDHistorialEmpleadoPeriodo not in (SELECT IDHistorialEmpleadoPeriodo FROM Facturacion.TblTimbrado with (nolock)) 
				THEN 
				DELETE;

END
GO

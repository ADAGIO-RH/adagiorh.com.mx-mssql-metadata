USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Cierrar un periodo de nómina
** Autor			: Jose Rafael Roman Gil
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2017-12-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-11-01			ANEUDY ABREU		Corrige bug al buscar los colaborador con pago en el periodo
										agregando un like para buscar los conceptos *550 y el IDTipoConcepto
										
										Refectoriza para quitar valores mágicos

EXEC [Nomina].[spCerrarPeriodoNomina]492,1,1

***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spCerrarPeriodoNomina]--421,1,1
(
	@IDPeriodo int,
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
		@IdsPedidos varchar(max),
		@especial bit,
		@IDTipoNomina int,
		@FechaInicioPago date,
		@FechaFinPago date,
		@empleados [RH].[dtEmpleados],
		@finiquito bit,

		@IDEmpleadoFiniquitoProceso int = 0,
		@ClaveEmpleado varchar(20),
		@fechaBaja Date,
		@FechaAntiguedad Date,

		@ID_ESTATUS_FINIQUITO_APLICAR INT = 2,
		@ID_ESTATUS_PRESTAMOS_NUEVO INT = 1,
		@ID_ESTATUS_PRESTAMOS_ACTIVO INT = 2,
		@ID_ESTATUS_PRESTAMOS_SALDADO INT = 4,
		@ID_TIPO_CONCEPTO_CONCEPTOS_TOTALES INT = 6,
		@ID_TIPO_CONCEPTO_CONCEPTOS_TOTALES_ASIMILADOS INT = 12,
		@Asimilado bit = 0
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
		select @IDTipoNomina = p.IDTipoNomina,
			   @FechaInicioPago = p.FechaFinIncidencia,
			   @FechaFinPago = p.FechaFinPago,
			   @finiquito = isnull(p.Finiquito,0),
               @especial = isnull(p.Especial,0),
			   @Asimilado = ISNULL(tn.Asimilados,0)
		from Nomina.tblCatPeriodos P with (nolock)
			inner join Nomina.tblCatTipoNomina tn with(nolock)
				on P.IDTipoNomina = tn.IDTipoNomina
		where p.IDPeriodo = @IDPeriodo

		IF(@finiquito=0)
		BEGIN
			PRINT 'NO FINIQUITO'
			INSERT INTO @empleados(IDEmpleado,IDCentroCosto,IDDepartamento,IDSucursal,IDPuesto
				,IDRegPatronal,IDCliente,IDEmpresa,IDArea,IDDivision,IDClasificacionCorporativa,IDRegion,IDRazonSocial)
			SELECT 
				E.IDEmpleado
				,CE.IDCentroCosto
				,DE.IDDepartamento
				,SE.IDSucursal
				,PE.IDPuesto
				,RE.IDRegPatronal
				,CLE.IDCliente
				,EE.IDEmpresa
				,AE.IDArea
				,DIE.IDDivision
				,CCE.IDClasificacionCorporativa
				,REE.IDRegion
				,RAE.IDRazonSocial
			 FROM RH.tblEmpleados E
				-- INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE 
				--     on DFE.IDEmpleado = E.IDEmpleado 
				--     AND DFE.IDUsuario = @IDUsuario
				INNER JOIN (
						SELECT DISTINCT DPI.IDEmpleado
						FROM NOMINA.tblDetallePeriodo DPI
						WHERE DPI.IDPeriodo=@IDPeriodo
					) AS EmpleadosDP  ON EmpleadosDP.IDEmpleado=E.IDEmpleado 
				LEFT JOIN [RH].[tblCentroCostoEmpleado] CE WITH(NOLOCK) ON E.IDEmpleado = CE.IDEmpleado 
					AND CE.FechaIni<= @FechaFinPago AND CE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblDepartamentoEmpleado] DE WITH(NOLOCK) ON E.IDEmpleado = DE.IDEmpleado 
					AND DE.FechaIni<= @FechaFinPago AND DE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblSucursalEmpleado] SE WITH(NOLOCK) ON E.IDEmpleado = SE.IDEmpleado 
					AND SE.FechaIni<= @FechaFinPago AND SE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblPuestoEmpleado] PE WITH(NOLOCK) ON E.IDEmpleado = PE.IDEmpleado 
					AND PE.FechaIni<= @FechaFinPago AND PE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblRegPatronalEmpleado] RE WITH(NOLOCK) ON E.IDEmpleado = RE.IDEmpleado 
					AND RE.FechaIni<= @FechaFinPago AND RE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblClienteEmpleado] CLE WITH(NOLOCK) ON E.IDEmpleado = CLE.IDEmpleado 
					AND CLE.FechaIni<= @FechaFinPago AND CLE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblEmpresaEmpleado] EE WITH(NOLOCK) ON E.IDEmpleado = EE.IDEmpleado 
					AND EE.FechaIni<= @FechaFinPago AND EE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblAreaEmpleado] AE WITH(NOLOCK) ON E.IDEmpleado = AE.IDEmpleado 
					AND AE.FechaIni<= @FechaFinPago AND AE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblDivisionEmpleado] DIE WITH(NOLOCK) ON E.IDEmpleado = DIE.IDEmpleado 
					AND DIE.FechaIni<= @FechaFinPago AND DIE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblClasificacionCorporativaEmpleado] CCE WITH(NOLOCK) ON E.IDEmpleado = CCE.IDEmpleado 
					AND CCE.FechaIni<= @FechaFinPago AND CCE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblRegionEmpleado] REE WITH(NOLOCK) ON E.IDEmpleado = REE.IDEmpleado 
					AND REE.FechaIni<= @FechaFinPago AND REE.FechaFin >= @FechaFinPago
				LEFT JOIN [RH].[tblRazonSocialEmpleado] RAE WITH(NOLOCK) ON E.IDEmpleado = RAE.IDEmpleado 
					AND RAE.FechaIni<= @FechaFinPago AND RAE.FechaFin >= @FechaFinPago

			--select * from @empleados
		END    
		ELSE
		BEGIN	
		PRINT 'FINIQUITO'
		
			select CF.IDEmpleado
				, e.ClaveEmpleado
				, cf.FechaBaja
				, isnull(cf.FechaAntiguedad,dateadd(day,-1,cf.FechaBaja)) FechaAntiguedad
			into #TempEmpleadosFiniquito
			from Nomina.tblControlFiniquitos cf with(nolock)
				inner join RH.tblEmpleados e with(nolock)
					on cf.IDEmpleado = e.IDEmpleado
			where cf.IDPeriodo = @IDPeriodo
				and cf.IDEstatusFiniquito = @ID_ESTATUS_FINIQUITO_APLICAR
		
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
				exec RH.spBuscarEmpleados                
					 @FechaIni=@FechaAntiguedad
					,@Fechafin=@fechaBaja 
					,@EmpleadoIni = @ClaveEmpleado
					,@EmpleadoFin = @ClaveEmpleado
					,@IDUsuario= @IDUsuario

					select @IDEmpleadoFiniquitoProceso = min(IDEmpleado) 
					from #TempEmpleadosFiniquito
					where IDEmpleado > @IDEmpleadoFiniquitoProceso
			END
		END


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

		--select * from #tempEmpleadosPeriodoAsimilado

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
			(ISNULL(p.MontoPrestamo,0)+ISNULL(p.Intereses,0)) - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		INTO #tempPrestamosSaldados
		from [Nomina].[tblPrestamos] p with (nolock)   
			inner join [Nomina].[tblCatTiposPrestamo] TP with (nolock) on p.IDTipoPrestamo = TP.IDTipoPrestamo
			left join [Nomina].[tblPrestamosFondoAhorro] pfa with (nolock) on p.IDPrestamo = pfa.IDPrestamo --and pfa.IDEmpleado = @IDEmpleado   
			inner join [Nomina].[tblCatEstatusPrestamo] EP with (nolock) on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
			inner join [RH].[tblEmpleados] e with (nolock) on P.IDEmpleado = e.IDEmpleado    
		where p.IDEstatusPrestamo in (@ID_ESTATUS_PRESTAMOS_NUEVO, @ID_ESTATUS_PRESTAMOS_ACTIVO)

		delete from #tempPrestamosSaldados where Balance > 0

		update p 
			set p.IDEstatusPrestamo = @ID_ESTATUS_PRESTAMOS_SALDADO
		from Nomina.tblPrestamos p
			join #tempPrestamosSaldados tp on p.IDPrestamo = tp.IDPrestamo

		update p
			set 
				p.DescontadaDeNomina = 1,
				p.FechaHoraDescuento = getdate(),
				p.IDPeriodo = @IDPeriodo
		from Comedor.tblPedidos p
			join (select cast(item as int) IDPedido from App.Split(@IdsPedidos,',')) idsP on idsP.IDPedido = p.IDPedido

	    update Nomina.tblSalariosMinimos
			set AjustarUMI = 0
	    WHERE YEAR(Fecha) = YEAR(@FechaInicioPago)
        EXEC [Scheduler].[spSchedulerNotificacionEspecial_CierrePeriodo] @IDPeriodo =@IDPeriodo
	END ELSE
	BEGIN

         UPDATE P
            SET P.IDEstatusPrestamo = @ID_ESTATUS_PRESTAMOS_ACTIVO
        FROM Nomina.tblDetallePeriodo DP WITH (NOLOCK)           
            INNER JOIN Nomina.tblCatTiposPrestamo CTP WITH (NOLOCK)
                ON CTP.IDConcepto = DP.IDConcepto                
            INNER JOIN Nomina.tblPrestamos P WITH (NOLOCK)
                ON P.IDPrestamo = DP.IDReferencia           
        WHERE dp.IDPeriodo = @IDPeriodo AND P.IDEstatusPrestamo = @ID_ESTATUS_PRESTAMOS_SALDADO


        UPDATE P
            SET P.IDEstatusPrestamo = @ID_ESTATUS_PRESTAMOS_NUEVO
        FROM Nomina.tblDetallePeriodo DP WITH (NOLOCK)                       
            INNER JOIN Nomina.tblCatConceptos C WITH (NOLOCK)
				ON dp.IDConcepto = c.IDConcepto AND c.Codigo IN ('144','167')
            INNER JOIN Nomina.tblPrestamos P WITH (NOLOCK)
                ON P.IDPrestamo = DP.IDReferencia           
        WHERE dp.IDPeriodo = @IDPeriodo AND P.IDEstatusPrestamo = @ID_ESTATUS_PRESTAMOS_ACTIVO

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

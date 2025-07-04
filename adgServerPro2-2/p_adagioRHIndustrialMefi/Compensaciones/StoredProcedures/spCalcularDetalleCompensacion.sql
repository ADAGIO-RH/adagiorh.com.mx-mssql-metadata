USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Compensaciones.spCalcularDetalleCompensacion 0 , 2 , 1

CREATE PROCEDURE [Compensaciones].[spCalcularDetalleCompensacion]
(
	@IDCompensacionesDetalle int = 0
	,@IDCompensacion int
	,@IDUsuario int 
)
AS
BEGIN

declare  
	   @SalarioMinimo decimal(18,2)
	   ,@IDCatTipoCompensacion int
	   ,@IDTipoNomina int
	   ,@IDMatrizIncremento int
	   ,@Fecha Date
	   ,@bPorcentaje bit
	   ,@bDiasSueldo bit
	   ,@bMonto bit
	   ,@Porcentaje Decimal(18,4)
	   ,@DiasSueldo Decimal(18,4)
	   ,@Monto Decimal(18,4)
	   ,@IDCliente int
	   ,@IDPeriodo int
	   ,@IDConcepto int
	   ;

	   DECLARE @json VARCHAR(MAX),	
		@MinAmplitud decimal(18,4),
		@maxAmplitud decimal(18,4)

	SELECT 
		@IDCatTipoCompensacion	= IDCatTipoCompensacion
		,@IDCliente				= IDCliente	
		,@IDTipoNomina			= IDTipoNomina
		,@IDPeriodo				= IDPeriodo	
		,@IDMatrizIncremento	= IDMatrizIncremento
		,@Fecha					= Fecha	
		,@bPorcentaje			= bPorcentaje	
		,@bDiasSueldo			= bDiasSueldo	
		,@bMonto				= bMonto
		,@Porcentaje			= Porcentaje
		,@DiasSueldo			= DiasSueldo
		,@Monto					= Monto
		,@IDConcepto			= IDConcepto
	FROM Compensaciones.TblCompensaciones with(nolock)
	WHERE IDCompensacion = @IDCompensacion

	
	Select top 1 @SalarioMinimo = isnull(SalarioMinimo,0)
	from Nomina.tblSalariosMinimos with(nolock)
	WHERE Fecha <= @Fecha
	and IDPais = 151 -- MEXICO
	order by Fecha desc

	declare @tempResponse as table (
		 IDCompensacionesDetalle int not null 
		,IDCompensacion			int not null 
		,IDEmpleado				int not null 
		,ClaveEmpleado			Varchar(255) not null
		,NombreCompleto			Varchar(255) not null
		,Departamento			Varchar(250) not null
		,Sucursal				Varchar(250) not null
		,Puesto					Varchar(250) not null
		,IndiceSalarial			Decimal(18,4)
		,IndiceSalarialNuevo	Decimal(18,4)
		,Salario				Decimal(18,4)
		,SalarioNuevo			Decimal(18,4)
		,SalarioDiario			Decimal(18,4)
		,SalarioDiarioNuevo		Decimal(18,4)
		,Compensacion			Decimal(18,4)
	);

	Declare @tableMatriz as table (
		Nivel		int,
		Amplitud	decimal(18,4),
		Valor		decimal(18,4)
	);
	declare @tableNiveles as table (
		Nivel		int,
		Minimo		decimal(18,2),
		Q1			decimal(18,2),
		Medio		decimal(18,2),
		Q3			decimal(18,2),
		Maximo		decimal(18,2),
		Amplitud	decimal(18,2),
		Progresion	decimal(18,2)
	);

	insert into  @tableNiveles
	SELECT 
	 Nivel
	,Minimo
	,Q1
	,Medio
	,Q3
	,Maximo
	,Amplitud
	,Progresion
	FROM [RH].[tblTabuladorSalarial] WITH(nolock)

	insert into @tableMatriz
	Select ValorNivelProgresion
		,ValorNivelAmplitud
		,Valor
	from Compensaciones.TblMatrizIncrementoDetalle WITH(nolock)
	WHERE IDMatrizIncremento = @IDMatrizIncremento

	select @MinAmplitud = min(Amplitud)
		 ,@maxAmplitud = MAX(Amplitud)	
	from @tableMatriz

	--select @MinAmplitud,@maxAmplitud
	IF(@IDCatTipoCompensacion = 1)
	BEGIN
		insert into @tempResponse
		Select 
		 isnull(C.IDCompensacionesDetalle,0) as IDCompensacionesDetalle			
		,isnull(C.IDCompensacion,@IDCompensacion)as IDCompensacion
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,isnull(C.IndiceSalarial,0.00) as IndiceSalarial		 			
		,isnull(C.IndiceSalarialNuevo,0.00) as IndiceSalarialNuevo		 			
		,isnull(M.SalarioDiario * 30.4,0.00) as Salario		 			
		,isnull(@SalarioMinimo * 30.4,0.00) as SalarioNuevo		 			
		,isnull(M.SalarioDiario,0.00) as SalarioDiario		 			
		,isnull(@SalarioMinimo,0.00) as SalarioDiarioNuevo		 			
		,isnull(C.Compensacion,0.00) as Compensacion
		FROM Compensaciones.TblCompensacionesDetalle C WITH(NOLOCK)
			inner join RH.tblEmpleadosMaster M with(nolock)
				on C.IDEmpleado = M.IDEmpleado
		WHERE IDCompensacion = @IDCompensacion
		and ((IDCompensacionesDetalle = @IDCompensacionesDetalle) OR (isnull(@IDCompensacionesDetalle,0)= 0))
	END

	IF(@IDCatTipoCompensacion = 2)
	BEGIN
		insert into @tempResponse
		Select 
		 isnull(C.IDCompensacionesDetalle,0) as IDCompensacionesDetalle			
		,isnull(C.IDCompensacion,@IDCompensacion)as IDCompensacion
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio) as IndiceSalarial		 			
		,(((isnull(M.SalarioDiario * 30.4 ,0.00)*matriz.Valor) + isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio) as IndiceSalarialNuevo	
		,isnull(M.SalarioDiario * 30.4,0.00) as Salario		 			
		,((isnull(M.SalarioDiario * 30.4 ,0.00)*matriz.Valor) + isnull(M.SalarioDiario * 30.4 ,0.00)) as SalarioNuevo		 			
		,isnull(M.SalarioDiario,0.00) as SalarioDiario		 			
		,((isnull(M.SalarioDiario ,0.00)*matriz.Valor) + isnull(M.SalarioDiario ,0.00))  as SalarioDiarioNuevo		 			
		,isnull(C.Compensacion,0.00) as Compensacion
		
		FROM Compensaciones.TblCompensacionesDetalle C WITH(NOLOCK)
			inner join RH.tblEmpleadosMaster M with(nolock)
				on C.IDEmpleado = M.IDEmpleado
			inner join RH.tblcatPosiciones posiciones with(nolock)
				on c.IDEmpleado = posiciones.IDEmpleado
			inner join RH.tblcatPlazas plazas with(nolock)
				on plazas.IDPlaza = Posiciones.IDPlaza
			left join @tableNiveles N
				on N.Nivel = plazas.IDNivelSalarial
			left join @tableMatriz matriz
				on matriz.Nivel = plazas.IDNivelSalarial
				and matriz.Amplitud =  CASE WHEN ((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio) <= @MinAmplitud THEN @MinAmplitud
											WHEN ((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio) >= @MAXAmplitud THEN @maxAmplitud
											ELSE ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1)
											END
		WHERE c.IDCompensacion = @IDCompensacion
		and ((IDCompensacionesDetalle = @IDCompensacionesDetalle) OR (isnull(@IDCompensacionesDetalle,0)= 0))

		--select * from @tempResponse
	END

	IF(@IDCatTipoCompensacion = 3)
	BEGIN
		insert into @tempResponse
		Select 
		 isnull(C.IDCompensacionesDetalle,0) as IDCompensacionesDetalle			
		,isnull(C.IDCompensacion,@IDCompensacion)as IDCompensacion
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,isnull(C.IndiceSalarial,0.00) as IndiceSalarial		 			
		,isnull(C.IndiceSalarialNuevo,0.00) as IndiceSalarialNuevo		 			
		,isnull(M.SalarioDiario * 30.4,0.00) as Salario		 			
		,((isnull(M.SalarioDiario * 30.4 ,0.00)*(@Porcentaje/100.00)) + isnull(M.SalarioDiario * 30.4 ,0.00)) as SalarioNuevo		 			
		,isnull(M.SalarioDiario,0.00) as SalarioDiario		 			
		,((isnull(M.SalarioDiario ,0.00)*(@Porcentaje/100.00)) + isnull(M.SalarioDiario ,0.00))  as SalarioDiarioNuevo		 		
		,isnull(C.Compensacion,0.00) as Compensacion
		FROM Compensaciones.TblCompensacionesDetalle C WITH(NOLOCK)
			inner join RH.tblEmpleadosMaster M with(nolock)
				on C.IDEmpleado = M.IDEmpleado
		WHERE IDCompensacion = @IDCompensacion
		and ((IDCompensacionesDetalle = @IDCompensacionesDetalle) OR (isnull(@IDCompensacionesDetalle,0)= 0))
	END

	IF(@IDCatTipoCompensacion = 4)
	BEGIN
		insert into @tempResponse
		Select 
		 isnull(C.IDCompensacionesDetalle,0) as IDCompensacionesDetalle			
		,isnull(C.IDCompensacion,@IDCompensacion)as IDCompensacion
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio) as IndiceSalarial		 			
		,(((isnull(M.SalarioDiario * 30.4 ,0.00)))/N.Medio) as IndiceSalarialNuevo	
		,isnull(M.SalarioDiario * 30.4,0.00) as Salario		 			
		,((isnull(M.SalarioDiario * 30.4 ,0.00))) as SalarioNuevo		 			
		,isnull(M.SalarioDiario,0.00) as SalarioDiario		 			
		,((isnull(M.SalarioDiario ,0.00)))  as SalarioDiarioNuevo	 		
		, CASE WHEN @bMonto = 1 THEN ((@Monto / 100.00) * (select top 1 Valor from @tableMatriz 
															WHERE Nivel = Plazas.IDNivelSalarial
															and (Amplitud <= CASE WHEN ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1) < @MinAmplitud THEN @MinAmplitud
																				  WHEN ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1) > @maxAmplitud THEN @maxAmplitud
																				  ELSE (ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1))
																				  END) 
															order by Valor asc)) * 100.00
			   WHEN @bDiasSueldo = 1 THEN (((M.SalarioDiario * @DiasSueldo) / 100.00) * (select top 1 Valor from @tableMatriz 
																							WHERE Nivel =Plazas.IDNivelSalarial
																							and (Amplitud <= CASE WHEN ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1) < @MinAmplitud THEN @MinAmplitud
																												  WHEN ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1) > @maxAmplitud THEN @maxAmplitud
																												  ELSE (ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1))
																												  END) 
																							order by Valor asc)) * 100.00
			   WHEN @bPorcentaje = 1 THEN (((M.SalarioDiario * 30.4) * @Porcentaje / 100.00) * (select top 1 Valor from @tableMatriz 
																									WHERE Nivel = Plazas.IDNivelSalarial
																									and (Amplitud <= CASE WHEN ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1) < @MinAmplitud THEN @MinAmplitud
																														  WHEN ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1) > @maxAmplitud THEN @maxAmplitud
																														  ELSE (ROUND(((isnull(M.SalarioDiario * 30.4 ,0.00))/N.Medio),1))
																														  END) 
																									order by Valor asc)) * 100.00
			   ELSE 0
			   END as Compensacion

		FROM Compensaciones.TblCompensacionesDetalle C WITH(NOLOCK)
			inner join RH.tblEmpleadosMaster M with(nolock)
				on C.IDEmpleado = M.IDEmpleado
			inner join RH.tblcatPosiciones posiciones with(nolock)
				on c.IDEmpleado = posiciones.IDEmpleado
			inner join RH.tblcatPlazas plazas with(nolock)
				on plazas.IDPlaza = Posiciones.IDPlaza
			left join @tableNiveles N
				on N.Nivel = plazas.IDNivelSalarial

		WHERE c.IDCompensacion = @IDCompensacion
		and ((IDCompensacionesDetalle = @IDCompensacionesDetalle) OR (isnull(@IDCompensacionesDetalle,0)= 0))

		--select @bMonto, @Monto
		--select * from @tempResponse
		----select * from @tableNiveles
		--select * from @tableMatriz
	END
	select * from @tempResponse


	MERGE Compensaciones.TblCompensacionesDetalle AS Target
	USING @tempResponse	AS Source
	ON Source.IDCompensacionesDetalle = Target.IDCompensacionesDetalle
	and Source.IDCompensacion = Target.IDCompensacion
    
	-- For Inserts
	WHEN NOT MATCHED BY Target THEN
		INSERT (
		IDEmpleado
		,IndiceSalarial
		,IndiceSalarialNuevo
		,Salario
		,SalarioNuevo
		,SalarioDiario
		,SalarioDiarioNuevo
		,Compensacion
		
		) 
		VALUES (
		 Source.IDEmpleado
		,Source.IndiceSalarial
		,Source.IndiceSalarialNuevo
		,Source.Salario
		,Source.SalarioNuevo
		,Source.SalarioDiario
		,Source.SalarioDiarioNuevo
		,Source.Compensacion
		)
    
	-- For Updates
	WHEN MATCHED THEN UPDATE SET
		TARGET.IDEmpleado			= SOURCE.IDEmpleado
		,TARGET.IndiceSalarial		= SOURCE.IndiceSalarial
		,TARGET.IndiceSalarialNuevo	= SOURCE.IndiceSalarialNuevo
		,TARGET.Salario				= SOURCE.Salario
		,TARGET.SalarioNuevo			= SOURCE.SalarioNuevo
		,TARGET.SalarioDiario		= SOURCE.SalarioDiario
		,TARGET.SalarioDiarioNuevo	= SOURCE.SalarioDiarioNuevo
		,TARGET.Compensacion			= SOURCE.Compensacion
		
    
	-- For Deletes
	WHEN NOT MATCHED BY Source and Target.IDCompensacion = @IDCompensacion THEN
		DELETE;

END
GO

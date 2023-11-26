USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Calcular el salario integrado.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-07-08

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [IMSS].[spCalcularSalarioIntegrado](  
    @RespetarAntiguedad bit ,
    @FechaMovimiento date ,
    @SalarioDiario Decimal(18,4),
    @SalarioVariable Decimal(18,4),    
	@IDUsuario	int ,
    @IDEmpleado int 
	
)as   
BEGIN	

    declare @fechaAntiguedad date ,
            @fechaIngreso date,            
            @fechaAntiguedadEmpleado date,
            @IDTipoPrestacion int,
            @UMA decimal (18,4),
            @factor decimal (18,4),
            @salarioIntegrado decimal (18,4);

    SELECT @fechaAntiguedadEmpleado=FechaAntiguedad,
            @IDTipoPrestacion=IDTipoPrestacion
    FROM RH.tblEmpleadosMaster where IDEmpleado=@IDEmpleado
    

    set @fechaAntiguedad = case when @RespetarAntiguedad =1 then @fechaAntiguedadEmpleado
                                    else  @FechaMovimiento end;

    set @fechaIngreso =@FechaMovimiento;
    
    declare @dtDetallePrestacion as table (
		IDTipoPrestacionDetalle int ,
        IDTipoPrestacion int ,
        TipoPrestacion varchar(100),
        Antiguedad  int , 
        DiasAguinaldo int , 
        DiasVacaciones int ,
        PrimaVacacional decimal(18,4),
        PorcentajeExtra decimal(18,4),
        DiasExtras int ,
        Factor decimal(18,4)			
	);
    declare @dtDetalleSalarioMinimo as table(
        IDSalarioMinimo int ,
        Fecha date,
        SalarioMinimo decimal(18,4),
        SalarioMinimoFronterizo decimal(18,4),
        UMA decimal(18,4),
        FactorDescuento decimal(18,4),
        IDPais int ,    
        AjustarUMI int
    )    

    insert into @dtDetallePrestacion
    exec [RH].[spBuscarCatTiposPrestacionesDetallePorFecha] @IDTipoPrestacion=@IDTipoPrestacion, @FechaAntiguedad=@fechaAntiguedad,@FechaMovimiento =@FechaMovimiento;

    insert into @dtDetalleSalarioMinimo 
    exec [Nomina].[spBuscarSalariosMinimosActual]

    select top 1 @UMA=UMA FROM @dtDetalleSalarioMinimo 
    select top 1 @factor=Factor FROM @dtDetallePrestacion

    set @salarioIntegrado =(@SalarioDiario * @factor) + @SalarioVariable

    select @salarioIntegrado
    select @UMA 
    IF @salarioIntegrado >= (@UMA * 25 ) AND @UMA > 0
    BEGIN
        set @salarioIntegrado= @UMA * 25;
    END 

    SELECT @salarioIntegrado as [Salario Integrado]

end
GO

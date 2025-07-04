USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spUICatTipoNomina](
	@IDTipoNomina int = null,
	@Descripcion Varchar(50) = '',
	@IDPeriodicidadPago int = 0,
	@IDPeriodo int = null,
	@IDCliente int = null,
	@IDPais int = null,
	@Asimilados bit = 0,
	@ConfigISRProporcional bit = 0,
    @IDISRProporcional int = null,
    @IDISRProporcionalFiniquito int = null,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUICatTipoNomina]',
		@Tabla		varchar(max) = '[Nomina].[tblCatTipoNomina]',
		@Accion		varchar(20)	= ''
	;

	SET @Descripcion = UPPER(@Descripcion)

	IF(@IDTipoNomina = 0 or @IDTipoNomina is null)
	BEGIN
		insert into Nomina.tblCatTipoNomina(Descripcion
											,IDPeriodicidadPago
											,IDPeriodo
											,IDCliente
											,IDPais
											,Asimilados
                                            ,ConfigISRProporcional
                                            ,IDISRProporcional
                                            ,IDISRProporcionalFiniquito
											)
		VALUES(@Descripcion,@IDPeriodicidadPago,null,@IDCliente, CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END, ISNULL(@Asimilados,0),@ConfigISRProporcional,@IDISRProporcional, @IDISRProporcionalFiniquito)

		set @IDTipoNomina = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].[tblCatTipoNomina] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoNomina = @IDTipoNomina
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].[tblCatTipoNomina] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoNomina = @IDTipoNomina

		UPDATE Nomina.tblCatTipoNomina
			set Descripcion = @Descripcion
				,IDPeriodicidadPago = @IDPeriodicidadPago
				,IDPeriodo = case when @IDPeriodo = 0 then null else @IDPeriodo end
				,IDCliente = @IDCliente
				,IDPais = CASE WHEN ISNULL(@IDPais,0) = 0 THEN NULL ELSE @IDPais END
				,Asimilados = ISNULL(@Asimilados,0)
                ,ConfigISRProporcional = ISNULL(@ConfigISRProporcional,0)
                ,IDISRProporcional =  @IDISRProporcional 
                ,IDISRProporcionalFiniquito =  @IDISRProporcionalFiniquito 
		WHERE IDTipoNomina = @IDTipoNomina

		select @NewJSON = a.JSON
		from [Nomina].[tblCatTipoNomina] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDTipoNomina = @IDTipoNomina
	END

	--Select 
	--	tp.IDTipoNomina,
	--	tp.Descripcion,
	--	tp.IDPeriodicidadPago,
	--	upper(pp.Descripcion) as PerioricidadPago,
	--	isnull(tp.IDPeriodo,0) as IDPeriodo,
	--	p.ClavePeriodo,
	--	ISNULL(C.IDCliente,0) as IDCliente,
	--	C.NombreComercial as Cliente
	--from Nomina.tblCatTipoNomina tp
	--	inner join Sat.tblCatPeriodicidadesPago pp
	--		on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago
	--	left join Nomina.tblCatPeriodos p	
	--		on tp.IDPeriodo = p.IDPeriodo
	--	Left Join RH.tblCatClientes c
	--		on tp.IDCliente = c.IDCliente
	--where (tp.IDTipoNomina = @IDTipoNomina)

	EXEC [Nomina].[spBuscarCatTipoNomina]
	 @IDCliente  = @IDCliente        
	,@IDUsuario  = @IDUsuario   
	,@IDTipoNomina  = @IDTipoNomina  


	EXEC [Seguridad].[spIUFiltrosUsuarios] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'TiposNomina'  
		 ,@ID = @IDTipoNomina   
		 ,@Descripcion = @Descripcion
		 ,@IDUsuarioLogin = @IDUsuario 

	exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
END
GO

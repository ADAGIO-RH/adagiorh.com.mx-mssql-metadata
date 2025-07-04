USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear y actualizar conceptos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-07-19		Aneudy Abreu		Se cambió el campo OrdenInsert por OrdenCalculo
								Se agregaron los campos: Captura		bit
													Calendario	bit
													LFT			bit
													Personalizada  bit
													ConDoblePago	bit
								Se eliminó el campo IDFrecuenciaConcepto
2018-07-19		Jose Roman		Se agrega nueva estructura por default para contemplar campos nuevos
								y validaciones para capturas.
2024-10-03		Jose Roman		Se agrega Columna de Presupuesto bit para ejecutar esos conceptos en
								el calculo de presupuesto.
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spIUCatConceptos]
(
	 @IDConcepto int 
	,@Codigo varchar(20) 
	,@Descripcion varchar(100) 
	,@IDTipoConcepto int
	,@Estatus bit
	,@Impresion bit 
	,@IDCalculo int 
	,@CuentaAbono varchar(50) 
	,@CuentaCargo varchar(50) 
	,@bCantidadMonto bit
	,@bCantidadDias  bit
	,@bCantidadVeces bit
	,@bCantidadOtro1 bit
	,@bCantidadOtro2 bit
	,@IDCodigoSAT int 
	,@NombreProcedure varchar(200) 
    ,@OrdenCalculo int
    ,@LFT		  bit
    ,@Personalizada  bit
    ,@ConDoblePago	  bit
	,@IDPais int
    ,@Presupuesto	  bit
	,@IDUsuario int
)
AS
BEGIN
    declare 
		@SQLCreateProcedure nvarchar(max)
		,@NombreProcedureSinSchema nvarchar(max)
		,@SPBody nvarchar(max)
		,@RecalcularOrdenCalculo int = 0
		,@OldJSON Varchar(Max) = ''
		,@NewJSON Varchar(Max)
		,@NombreSP	varchar(max) = '[Nomina].[spIUCatConceptos]'
		,@Tabla varchar(max) = '[Nomina].[tblCatConceptos]'
		,@Accion varchar(20)
		,@MaxOrden INT;

    if ((@OrdenCalculo is null) or (@OrdenCalculo = 0))
    begin
	   select @OrdenCalculo=isnull(Max(isnull(OrdenCalculo,0))+1,1) from Nomina.tblCatConceptos
    end else
	  set @RecalcularOrdenCalculo = 1;
	  

    select @SQLCreateProcedure=m.definition
	from [sys].[all_objects] o 
		join [sys].[schemas] s on [o].[schema_id] = [s].[schema_id]
		left join [sys].[all_sql_modules] m on [o].[object_id] = [m].[object_id]
	where '['+[s].[name]+'].['+[o].[name]+']' = '[Nomina].[spTemplateConcepto]'

	if (@SQLCreateProcedure is null or len(@SQLCreateProcedure) = 0)
	begin
		raiserror('No existe el template para crear los Conceptos, contacte a soporte técnico',16,1);
		return;
	end;

	if (@IDConcepto = 0 or @IDConcepto is null)
	begin
		if exists (select 1 from [Nomina].[tblCatConceptos] where Codigo=@Codigo)
		begin
			exec [App].[spObtenerError] @IDUsuario=@IDUsuario,@CodigoError='0406001'
			return;
		end;

		set @NombreProcedure= '[Nomina].[spConcepto_'+@Codigo+']';
		--   set @NombreProcedureSinSchema= 'spConcepto_'+@Codigo;
	   
		insert into Nomina.tblCatConceptos(Codigo,Descripcion,IDTipoConcepto,Estatus
				,Impresion,IDCalculo,CuentaAbono,CuentaCargo,bCantidadMonto,bCantidadDias,bCantidadVeces
				,bCantidadOtro1,bCantidadOtro2,IDCodigoSAT,NombreProcedure,OrdenCalculo,LFT,Personalizada,ConDoblePago, IDPais, Presupuesto)
		values(@Codigo,upper(@Descripcion),@IDTipoConcepto,@Estatus
				,@Impresion,@IDCalculo,@CuentaAbono,@CuentaCargo,@bCantidadMonto,@bCantidadDias,@bCantidadVeces
				,@bCantidadOtro1,@bCantidadOtro2,@IDCodigoSAT,@NombreProcedure,@OrdenCalculo,@LFT,@Personalizada,@ConDoblePago, @IDPais, ISNULL(@Presupuesto,0))

		set @IDConcepto = @@IDENTITY;

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from Nomina.tblCatConceptos b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDConcepto = @IDConcepto

		-- exec @MaxOrden = [Reportes].[spActualizarOrdenReporteRayas] @IDConcepto =@IDConcepto, @OldIndex = 0, @NewIndex = @OrdenCalculo, @IDUsuario=@IDUsuario

 		insert into Reportes.tblConfigReporteRayas(IDConcepto,Orden,Impresion)
        values(@IDConcepto, @OrdenCalculo,0 )
        
		
		if not exists (select 1 
				from [sys].[objects] o
					join [sys].[schemas] s on ([o].[schema_id] = [s].[schema_id]) and [s].[name] = 'Nomina'
					where [o].[type] = 'P' and ('['+[s].[name]+'].['+[o].[name]+']') = @NombreProcedure)
		begin
			set @SQLCreateProcedure = REPLACE(@SQLCreateProcedure,'{{CodigoConcepto}}',@Codigo)
			set @SQLCreateProcedure = REPLACE(@SQLCreateProcedure,'{{DescripcionConcepto}}',upper(@Descripcion))
			set @SQLCreateProcedure = REPLACE(@SQLCreateProcedure,'[Nomina].[spTemplateConcepto]',@NombreProcedure)

			print @SQLCreateProcedure
			execute(@SQLCreateProcedure); 
		end;
    end else
    begin
		select @OldJSON = a.JSON 
			,@Accion = 'UPDATE'
		from Nomina.tblCatConceptos b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDCalculo = @IDConcepto

		update Nomina.tblCatConceptos
		set
			Codigo				  = @Codigo
			,Descripcion			  = upper(@Descripcion)
			,IDTipoConcepto		  = @IDTipoConcepto
			,Estatus			  = @Estatus
			,Impresion			  = @Impresion
			,IDCalculo			  = @IDCalculo
			,CuentaAbono			  = @CuentaAbono
			,CuentaCargo			  = @CuentaCargo
			,bCantidadMonto		  = @bCantidadMonto
			,bCantidadDias		  = @bCantidadDias
			,bCantidadVeces		  = @bCantidadVeces
			,bCantidadOtro1		  = @bCantidadOtro1
			,bCantidadOtro2		  = @bCantidadOtro2
			,IDCodigoSAT			  = @IDCodigoSAT
			,NombreProcedure		  = @NombreProcedure
			,OrdenCalculo		  = @OrdenCalculo
			,LFT				  = @LFT
			,Personalizada		  = @Personalizada
			,ConDoblePago		  = @ConDoblePago
			,IDPais				  = @IDPais
			,@Presupuesto		  = ISNULL(@Presupuesto,0)
		where IDConcepto = @IDConcepto
    end;

     if (@RecalcularOrdenCalculo = 1)
    begin
	   exec [Nomina].[spActualizarOrdenCalculo] @IDConcepto =@IDConcepto 
	   ,@OldIndex = 0  
	   ,@NewIndex = @OrdenCalculo
    end;

	select @NewJSON = a.JSON
	from Nomina.tblCatConceptos b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDConcepto = @IDConcepto

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON


    exec [Nomina].[spBuscarCatConceptos] @IDConcepto= @IDConcepto

   

END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [STPS].[spIUProgramasCapacitacionDC2]
(
	@IDProgramaCapacitacion int  = 0,
	@IDEmpresa int ,
	@IDRegPatronal int ,
	@Email Varchar(MAX) null,
	@Fax Varchar(MAX) null,
	@QtyTrabajadoresConsiderados int null,
	@Mujeres int null,
	@Hombres int null,
	@ObjetivoActualizar int null,
	@ObjetivoPrevenir int null,
	@ObjetivoIncrementar int null,
	@ObjetivoMejorar int null,
	@ObjetivoPreparar int null,
	@ModalidadEspecificos bit null,
	@ModalidadComunes bit null,
	@ModalidadGeneral bit null,
	@NumeroEstablecimientos int null,
	@NumeroEtapas int null,
	@FechaInicio date null,
	@FechaFin date,
	@RegPatronalesAdicionales Varchar(max) null,
	@RepresentanteLegal Varchar(max) null,
	@FechaElaboracion date null,
	@LugarElaboracion Varchar(max) null,
	@IDUsuario int
)
AS
BEGIN

	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)



	IF (@IDProgramaCapacitacion = 0 or @IDProgramaCapacitacion is null)
	BEGIN
	
	
		INSERT INTO [STPS].[tblProgramasCapacitacionDC2]
				   (
					IDEmpresa
					,IDRegPatronal
					,Email
					,Fax
					,QtyTrabajadoresConsiderados
					,Mujeres
					,Hombres
					,ObjetivoActualizar
					,ObjetivoPrevenir
					,ObjetivoIncrementar
					,ObjetivoMejorar
					,ObjetivoPreparar
					,ModalidadEspecificos
					,ModalidadComunes
					,ModalidadGeneral
					,NumeroEstablecimientos
					,NumeroEtapas
					,FechaInicio
					,FechaFin
					,RegPatronalesAdicionales
					,RepresentanteLegal
					,FechaElaboracion
					,LugarElaboracion


				   )
			 VALUES
				   (
				    @IDEmpresa
					,@IDRegPatronal
					,@Email
					,@Fax
					,@QtyTrabajadoresConsiderados
					,@Mujeres
					,@Hombres
					,@ObjetivoActualizar
					,@ObjetivoPrevenir
					,@ObjetivoIncrementar
					,@ObjetivoMejorar
					,@ObjetivoPreparar
					,@ModalidadEspecificos
					,@ModalidadComunes
					,@ModalidadGeneral
					,@NumeroEstablecimientos
					,@NumeroEtapas
					,@FechaInicio
					,@FechaFin
					,@RegPatronalesAdicionales
					,@RepresentanteLegal
					,@FechaElaboracion
					,@LugarElaboracion
				   )

			set @IDProgramaCapacitacion = @@IDENTITY

		select @NewJSON = a.JSON from [STPS].[tblProgramasCapacitacionDC2] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProgramaCapacitacion = @IDProgramaCapacitacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[STPS].[tblProgramasCapacitacionDC2]','[STPS].[spIUProgramasCapacitacionDC2]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		
		select @OldJSON = a.JSON from [STPS].[tblProgramasCapacitacionDC2] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProgramaCapacitacion = @IDProgramaCapacitacion

		UPDATE [STPS].[tblProgramasCapacitacionDC2]
		   SET  
				
				IDEmpresa						= @IDEmpresa
				,IDRegPatronal					= @IDRegPatronal
				,Email							= @Email
				,Fax							= @Fax
				,QtyTrabajadoresConsiderados	= @QtyTrabajadoresConsiderados
				,Mujeres						= @Mujeres
				,Hombres						= @Hombres
				,ObjetivoActualizar				= @ObjetivoActualizar
				,ObjetivoPrevenir				= @ObjetivoPrevenir
				,ObjetivoIncrementar			= @ObjetivoIncrementar
				,ObjetivoMejorar				= @ObjetivoMejorar
				,ObjetivoPreparar				= @ObjetivoPreparar
				,ModalidadEspecificos			= @ModalidadEspecificos
				,ModalidadComunes				= @ModalidadComunes
				,ModalidadGeneral				= @ModalidadGeneral
				,NumeroEstablecimientos			= @NumeroEstablecimientos
				,NumeroEtapas					= @NumeroEtapas
				,FechaInicio					= @FechaInicio
				,FechaFin						= @FechaFin
				,RegPatronalesAdicionales		= @RegPatronalesAdicionales
				,RepresentanteLegal				= @RepresentanteLegal
				,FechaElaboracion				= @FechaElaboracion
				,LugarElaboracion				= @LugarElaboracion
		 WHERE IDProgramaCapacitacion = @IDProgramaCapacitacion

		 select @NewJSON = a.JSON from [STPS].[tblProgramasCapacitacionDC2] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDProgramaCapacitacion = @IDProgramaCapacitacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[STPS].[tblProgramasCapacitacionDC2','[STPS].[spIUProgramasCapacitacionDC2]','UPDATE',@NewJSON,@OldJSON

	END
	
END
GO

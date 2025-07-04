USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Realiza las distintas validaciones a las checadas
** Autor			: Joseph Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2017-01-01
** Paremetros		:              

** DataTypes Relacionados: 

	DECLARE 
		@Valida bit = 1,      
		@Mensaje Varchar(1000),    
		@EsRepetida bit= 0
	;

	exec [Asistencia].[spValidarChecada] 
		@IDEmpleado  = 1279,
		@FechaOrigen = '2021-09-14',
		@Tipochecada = 'ET',
		@IDLector	 = 15,
		@dtFechaZonaHoraria = '2019-05-05 10:59:14.010',
		@outChecadaValida = @Valida output,      
		@outMensajeValidacion = @Mensaje output,
		@outEsRepetida = @EsRepetida output  

	select @Valida as Valida, @Mensaje as Mensaje, @EsRepetida as EsRepetida

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spValidarChecada](              
	@IDEmpleado int,    
	@dtEmpleados2 [RH].[dtEmpleados] readonly,          
	@FechaOrigen Date,              
	@Tipochecada Varchar(10),              
	@IDLector int,              
	@dtFechaZonaHoraria datetime,              
	@outChecadaValida bit output,              
	@outMensajeValidacion Varchar(MAX) output,
	@outEsRepetida bit output              
)              
AS              
BEGIN              
  
	SET DATEFORMAT ymd;            
              
	declare               
		--@IDEmpleado int,              
		@ClaveEmpleado varchar(20),              
		--@FechaOrigen Date,              
		--@Tipochecada Varchar(10),              
		--@IDLector int,  
        @IDTipoLector varchar(100),            
		@dtEmpleados [RH].[dtEmpleados],              
		@ChecadaValida bit = 1,              
		@MensajeValidacion Varchar(MAX),              
		--@dtFechaZonaHoraria datetime,              
		@UltimaChecada Datetime,              
		@TiempoEntreChecada int,              
		@tipoContrato varchar(10),              
		@Incidencia varchar(100),            
		@Vigente bit = 0,
		@EsRepetida bit = 0,
		 @CustomeProcedure Varchar(max)
	;      
    
		SELECT top 1 @CustomeProcedure = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPCustomValidarChecadas'

		IF(ISNULL(@CustomeProcedure,'') <> '')
		BEGIN
			print 'custom'
			exec sp_executesql N'exec @miSP @IDEmpleado ,@dtEmpleados2 ,@FechaOrigen ,@TipoChecada , @IDLector, @dtFechaZonaHoraria, @outChecadaValida output, @outMensajeValidacion output, @outEsRepetida output'                   
				,N' @IDEmpleado int        
				,@dtEmpleados2 [RH].[dtEmpleados] readonly
				,@FechaOrigen date     
				,@Tipochecada  Varchar(10) 
				,@IDLector	int  
				,@dtFechaZonaHoraria datetime
				,@outChecadaValida bit output
				,@outMensajeValidacion Varchar(MAX) output
				,@outEsRepetida bit output    
				,@miSP varchar(MAX)',                          
				@IDEmpleado				= @IDEmpleado,      
				@dtEmpleados2			= @dtEmpleados,
				@FechaOrigen			= @FechaOrigen,      
				@Tipochecada			= @TipoChecada,      
				@IDLector				= @IDLector,      
				@dtFechaZonaHoraria		= @dtFechaZonaHoraria,      
				@outChecadaValida		= @ChecadaValida output,      
				@outMensajeValidacion	= @MensajeValidacion output,
				@outEsRepetida			= @EsRepetida output                
				,@miSP = @CustomeProcedure ; 

		      
				
		END
		ELSE
		BEGIN
			print 'Core'
			exec Asistencia.spCoreValidarChecada      
				@IDEmpleado				= @IDEmpleado,      
				@dtEmpleados2			= @dtEmpleados,
				@FechaOrigen			= @FechaOrigen,      
				@Tipochecada			= @TipoChecada,      
				@IDLector				= @IDLector,      
				@dtFechaZonaHoraria		= @dtFechaZonaHoraria,      
				@outChecadaValida		= @ChecadaValida output,      
				@outMensajeValidacion	= @MensajeValidacion output,
				@outEsRepetida			= @EsRepetida output         
		END

		select  @outChecadaValida		= @ChecadaValida       
			,@outMensajeValidacion	= @MensajeValidacion
			,@outEsRepetida			= @EsRepetida      
              
		RETURN 

END
GO

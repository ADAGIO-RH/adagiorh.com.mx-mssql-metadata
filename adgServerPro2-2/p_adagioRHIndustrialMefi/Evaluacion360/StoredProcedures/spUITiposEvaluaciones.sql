USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Evaluacion360.spUITiposEvaluaciones
	@IDTipoEvaluacion int = 0
    ,@TiposDeGrupos VARCHAR(max)=NULL
    ,@IDUsuario int
	,@Traduccion nvarchar(max)
    ,@BackGroundColor VARCHAR(max)=NULL
    ,@FontColor VARCHAR(max)=NULL

    AS
BEGIN
    	
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @Traduccion=App.UpperJSONKeys(@Traduccion, 'Nombre')

    if (@IDTipoEvaluacion=0 OR @IDTipoEvaluacion Is null)
    BEGIN  

    if((select max(IDTipoEvaluacion) from [Evaluacion360].[tblCatTiposEvaluaciones]) < 1000)
        begin
        select @IDTipoEvaluacion=1000
        END
        ELSE
        BEGIN
        select @IDTipoEvaluacion = max(IDTipoEvaluacion)+1 from [Evaluacion360].[tblCatTiposEvaluaciones]
    END  

        INSERT INTO [Evaluacion360].[tblCatTiposEvaluaciones] 
				   ([IDTipoEvaluacion]
                   ,[TiposDeGrupos]
				   ,[Traduccion]
                   ,[BackGroundColor]
                   ,[FontColor])
			 VALUES
				   (				 
				   @IDTipoEvaluacion
				   ,@TiposDeGrupos				 
				   ,case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
                   ,@BackGroundColor
                   ,@FontColor
                   )
    END
    ELSE
    BEGIN
        update [Evaluacion360].[tblCatTiposEvaluaciones] 
				set 
			
                    Traduccion	= case when ISJSON(@Traduccion) > 0 then @Traduccion else null end
                    ,TiposDeGrupos = @TiposDeGrupos
                    ,BackGroundColor = @BackGroundColor
                    ,FontColor =@FontColor
			where IDTipoEvaluacion = @IDTipoEvaluacion
    END

END

--alter table [Evaluacion360].[tblCatTiposEvaluaciones] add BackGroundColor varchar(255) null,  FontColor varchar(255) null

-- select * from [Evaluacion360].[tblCatTiposEvaluaciones] --where IDTipoEvaluacion= 5
-- delete from  [Evaluacion360].[tblCatTiposEvaluaciones] where IDTipoEvaluacion= 0
GO

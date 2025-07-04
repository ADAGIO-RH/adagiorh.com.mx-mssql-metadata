USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblPreguntasExtrasEncuestas](
	[IDPreguntaExtraEncuesta] [int] IDENTITY(1,1) NOT NULL,
	[IDEncuesta] [int] NOT NULL,
	[IDTipoPreguntaExtra] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Pregunta] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Placeholder] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RespuestaLarga] [bit] NOT NULL,
	[Requerida] [bit] NOT NULL,
	[FechaHoraRegistro] [datetime] NULL,
	[IDUsuarioCrea] [int] NOT NULL,
 CONSTRAINT [Pk_Norma35TblPreguntasExtrasEncuestas_IDPreguntaExtraEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDPreguntaExtraEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas] ADD  CONSTRAINT [D_Norma35TblPreguntasExtrasEncuestas_RespuestaLarga]  DEFAULT ((0)) FOR [RespuestaLarga]
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas] ADD  CONSTRAINT [D_Norma35TblPreguntasExtrasEncuestas_Requerida]  DEFAULT ((1)) FOR [Requerida]
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas] ADD  CONSTRAINT [D_Norma35TblPreguntasExtrasEncuestas_FechaHoraRegistro]  DEFAULT (getdate()) FOR [FechaHoraRegistro]
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblCatTiposPreguntasExtras_Norma35TblPreguntasExtrasEncuestas_IDTipoPreguntaExtra] FOREIGN KEY([IDTipoPreguntaExtra])
REFERENCES [Norma35].[tblCatTiposPreguntasExtras] ([IDTipoPreguntaExtra])
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas] CHECK CONSTRAINT [Fk_Norma35TblCatTiposPreguntasExtras_Norma35TblPreguntasExtrasEncuestas_IDTipoPreguntaExtra]
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_Norma35TblEncuestas_Norma35TtblPreguntasExtrasEncuestas_IDEncuesta] FOREIGN KEY([IDEncuesta])
REFERENCES [Norma35].[tblEncuestas] ([IDEncuesta])
ON DELETE CASCADE
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas] CHECK CONSTRAINT [Fk_Norma35TblEncuestas_Norma35TtblPreguntasExtrasEncuestas_IDEncuesta]
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_Norma35TblPreguntasExtrasEncuestas_IDUsuarioCrea] FOREIGN KEY([IDUsuarioCrea])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Norma35].[tblPreguntasExtrasEncuestas] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_Norma35TblPreguntasExtrasEncuestas_IDUsuarioCrea]
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblDriversToursTaken](
	[IDDriverTourTaken] [int] IDENTITY(1,1) NOT NULL,
	[IDDriverTour] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_AppTblDriversToursTaken_IDDriverTourTaken] PRIMARY KEY CLUSTERED 
(
	[IDDriverTourTaken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblDriversToursTaken] ADD  CONSTRAINT [D_AppTblDriversToursTaken_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [App].[tblDriversToursTaken]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblDriversToursTaken_AppTblDriversTours_IDDriverTour] FOREIGN KEY([IDDriverTour])
REFERENCES [App].[tblDriversTours] ([IDDriverTour])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblDriversToursTaken] CHECK CONSTRAINT [Fk_AppTblDriversToursTaken_AppTblDriversTours_IDDriverTour]
GO
ALTER TABLE [App].[tblDriversToursTaken]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblDriversToursTaken_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblDriversToursTaken] CHECK CONSTRAINT [Fk_AppTblDriversToursTaken_SeguridadTblUsuarios_IDUsuario]
GO
